require 'spec_helper'

describe SubscriptionManager do
  let(:subscriber)   { create_user(email: 'szinin@gmail.com') }
  let(:another_user) { create_profile(email: 'another@user.com') }

  subject(:manager) { described_class.new(subscriber: subscriber) }

  describe '#unsubscribe' do
    before { manager.subscribe_to(another_user) }

    it do
      expect { manager.unsubscribe }.to change { another_user.subscribers_count }.by(-1)
    end

    context 'fake' do
      before { manager.subscribe_to(another_user, fake: true) }

      it do
        expect { manager.unsubscribe }.to change { another_user.subscribers_count }.by(-1)
      end

      it do
        expect { manager.unsubscribe }.not_to change { FeedEvent.count }
      end
    end
  end

  describe '#subscribe_to' do
    context 'another user' do
      subject { manager.subscribe_to(another_user) }

      it { should be_a Subscription }
      it { should be_valid }
      it { should_not be_new_record }

      specify do
        expect { manager.subscribe_to(another_user) }.to change { Subscription.count }.by(1)
      end

      context 'fake' do
        subject(:subscribe) { manager.subscribe_to(another_user, fake: true) }

        it { should be_a Subscription }
        it { should be_valid }
        it { should_not be_new_record }
        it { should be_fake }

        specify do
          expect { subscribe }.to create_record(Subscription)
        end

        it do
          expect { subscribe }.not_to create_record(FeedEvent)
        end

        context 'with fake user' do
          let(:subscriber) { User.fake }

          it { should be_a Subscription }
          it { should be_valid }
          it { should_not be_new_record }
          it { should be_fake }
          its(:user) { should eq(subscriber) }
          it { expect { subscribe }.to create_record(Subscription).matching(target_user: another_user, user: subscriber) }
        end

        context 'subscribing more than 4 times' do
          it 'does not ban the subscriber' do
            5.times do
              manager.subscribe_to(another_user, fake: true)
            end

            expect(subscriber.reload.locked?).to eq(false)
          end
        end
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
          expect { manager.subscribe_to(another_user) rescue nil }.not_to create_event(:subscription_created)
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
            expect { manager.subscribe_to(another_user) rescue nil }.not_to create_event(:subscription_created)
          end
        end
      end

      context 'subscribing more than 4 times' do
        before do
          manager.subscribe_to(create_profile(email: 'another_1@user.com'))
          manager.subscribe_to(create_profile(email: 'another_2@user.com'))
          manager.subscribe_to(create_profile(email: 'another_3@user.com'))
          manager.subscribe_to(create_profile(email: 'another_4@user.com'))
        end

        it 'locks an account' do
          expect { manager.subscribe_to(another_user) }.to change { subscriber.locked? }.from(false).to(true)
        end

        context '48 hours passed' do
          it 'allows subscribing' do
            Timecop.travel(48.hours.since) do
              expect { manager.subscribe_to(another_user) }.not_to change { subscriber.locked? }.from(false)
            end
          end
        end

        context 'more than 5 subscriptions in 48 hours' do
          before do
            manager.subscribe_to(create_profile(email: 'another_5@user.com'))
          end

          it 'locks an account' do
            expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError, /locked/)
          end

          it 'does not subscribe' do
            expect { manager.subscribe_to(another_user) rescue nil }.not_to create_record(Subscription)
          end

          context '48 hours passed' do
            it 'does not allow subscribing' do
              Timecop.travel(48.hours.since) do
                expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError, /locked/)
              end
            end
          end
        end
      end
    end

    context 'any unsubscribable thing' do
      specify do
        expect { manager.subscribe_to(Subscription) }.to raise_error(ArgumentError, /Cannot subscribe/)
      end

      it 'does not create subscription_created event' do
        expect { manager.subscribe_to(Subscription) rescue nil }.not_to create_event(:subscription_created)
      end
    end
  end

  describe '#restore' do
    before { StripeMock.start }
    after { StripeMock.stop }

    let!(:subscription) do
      manager.subscribe_to(another_user)
    end

    context 'removed subscription' do
      before do
        manager.unsubscribe
      end

      specify do
        expect { manager.restore }.to change { subscription.removed? }.from(true).to(false)
      end

      context 'changed costs' do
        before do
          UserProfileManager.new(another_user).change_cost!(cost: 300, update_existing_subscriptions: false)
        end

        it 'updates cost to new value' do
          expect { manager.restore }.to change { subscription.reload.cost }.from(500).to(300)
        end
      end
    end

    context 'rejected subscription' do
    let(:subscriber) do
      create_user(email: 'szinin@gmail.com').tap do |u|
        UserProfileManager.new(u).update_cc_data(number: '4242424242424242', cvc: '123', expiry_month: 12, expiry_year: 19,
          address_line_1: 'test', address_line_2: 'test', state: 'test', city: 'test', zip: '12345')
      end
    end

      before do
        manager.reject
      end

      it 'tries to retry payment' do
        expect { manager.restore }.to change { subscription.rejected? }.from(true).to(false)
      end

      context 'paid subscription' do
        let!(:subscription) do
          manager.subscribe_and_pay_for(another_user)
        end

        before do
          manager.reject
        end

        it 'restores subscription' do
          expect { manager.restore }.to change { subscription.rejected? }.from(true).to(false)
        end

        it do
          expect { manager.restore }.to change { subscription.rejected_at }.to(nil)
        end

        it do
          expect { manager.restore }.not_to change { Payment.count }
        end

        it do
          expect { manager.restore }.not_to change { PaymentFailure.count }
        end
      end
    end
  end
end
