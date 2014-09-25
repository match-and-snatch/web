require 'spec_helper'

describe SubscriptionManager do
  let(:subscriber)   { create_user(email: 'szinin@gmail.com') }
  let(:another_user) { create_profile(email: 'another@user.com') }

  subject(:manager) { described_class.new(subscriber: subscriber) }

  describe '#subscribe_to' do
    context 'another user' do
      subject { manager.subscribe_to(another_user) }

      it { should be_a Subscription }
      it { should be_valid }
      it { should_not be_new_record }

      specify do
        expect { manager.subscribe_to(another_user) }.to change { Subscription.count }.by(1)
      end

      it 'creates subscription_created event' do
        expect { manager.subscribe_to(another_user) }.to create_event(:subscription_created)
      end

      it 'activates subscriber if he is not yet active' do
        expect { manager.subscribe_to(another_user) }.to change { subscriber.reload.activated? }.to(true)
      end

      it 'sets current cost from user' do
        expect(subject.cost).to eq(another_user.cost)
      end

      context 'already subscribed' do
        let!(:subscription) do
          manager.subscribe_to(another_user)
        end

        it 'does not allow to subscribe twice' do
          expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError)
        end

        it 'does not create subscription_created event twice' do
          expect { manager.subscribe_to(another_user) }.not_to create_event(:subscription_created)
        end

        context 'unsubscribed subscription' do
          before { StripeMock.start }
          after { StripeMock.stop }

          let!(:subscription) do
            Timecop.freeze 32.days.ago do
              manager.subscribe_to(another_user)
            end
          end

          before do
            described_class.new(subscriber: subscriber, subscription: subscription).unsubscribe
          end

          specify do
            expect { manager.subscribe_to(another_user) }.not_to raise_error
          end

          it 'subscribes user back' do
            expect { manager.subscribe_to(another_user) }.to change { subscriber.subscribed_to?(another_user) }.from(false).to(true)
          end

          it 'creates subscription_created event' do
            expect { manager.subscribe_to(another_user) }.to create_event(:subscription_created)
          end

          it 'does not create duplicate subscription' do
            expect { manager.subscribe_to(another_user) rescue nil }.not_to change { Subscription.count }
          end
        end

        context 'failed subscription' do
          before do
            described_class.new(subscriber: subscriber, subscription: subscription).reject
          end

          it 'does not allow to subscribe twice' do
            expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError)
          end

          it 'does not create duplicate subscription' do
            expect { manager.subscribe_to(another_user) rescue nil }.not_to change { Subscription.count }
          end

          it 'does not create subscription_created event' do
            expect { manager.subscribe_to(another_user) }.not_to create_event(:subscription_created)
          end
        end
      end
    end

    context 'any unsubscribable thing' do
      specify do
        expect { manager.subscribe_to(Subscription) }.to raise_error(ArgumentError, /Cannot subscribe/)
      end

      it 'does not create subscription_created event' do
        expect { manager.subscribe_to(Subscription) }.not_to create_event(:subscription_created)
      end
    end
  end

  describe '#restore' do
    let!(:subscription) do
      manager.subscribe_to(another_user)
    end
    before { StripeMock.start }
    after { StripeMock.stop }

    context 'removed subscription' do
      before do
        manager.unsubscribe
      end

      specify do
        expect { manager.restore }.to change { subscription.removed? }.from(true).to(false)
      end

      context 'changed costs' do
        before do
          UserProfileManager.new(another_user).update_cost(3, update_existing_subscriptions: false)
        end

        it 'updates cost to new value' do
          expect { manager.restore }.to change { subscription.reload.cost }.from(500).to(300)
        end

        it 'creates subscription_created event' do
          expect { manager.restore }.to create_event(:subscription_created)
        end
      end
    end

    context 'rejected subscription' do
      before do
        manager.reject
      end

      it 'tries to retry payment' do
        expect { manager.restore }.to change { subscription.rejected? }.from(true).to(false)
      end

      it 'creates subscription_created event' do
        expect { manager.restore }.to create_event(:subscription_created)
      end
    end
  end
end
