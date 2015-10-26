require 'spec_helper'

describe CurrentUserDecorator do
  let(:user) { User.new }
  subject { described_class.new(user) }

  describe '#can?' do
    context 'admin' do
      let(:user) { User.new is_admin: true }

      describe 'dialogues' do
        let(:user) { create_user }
        let(:foreigner) { create_user email: 'foreigner@gmail.com' }
        let(:user_dialogue) { MessagesManager.new(user: user).create(target_user: user, message: 'test').dialogue }
        let(:foreign_dialogue) { MessagesManager.new(user: foreigner).create(target_user: foreigner, message: 'test').dialogue }

        it 'can see it is own dialogues' do
          expect(subject.can?(:see, user_dialogue)).to eql(true)
        end

        it 'cannot see foreign messages' do
          expect(subject.can?(:see, foreign_dialogue)).to eql(false)
        end
      end
    end
  end

  describe '#==' do
    let(:user) { create_user }

    specify do
      expect(subject).to eq(user)
    end

    specify do
      expect(subject).to eq(subject)
    end

    specify do
      expect(subject).not_to eq(User.new)
    end
  end

  describe '#latest_subscriptions' do
    let(:user) { create_user }

    context 'without subscriptions' do
      specify do
        expect(subject.latest_subscriptions).to eq([])
      end
    end

    context 'with subscriptions' do
      before do
        StripeMock.start
      end

      after do
        StripeMock.stop
      end

      before do
        UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
        user.reload
      end

      let!(:old_subscription) do
        Timecop.freeze 32.days.ago do
          SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create_profile email: 'target2@user.com')
        end
      end

      let!(:old_removed_subscription) do
        Timecop.freeze 32.days.ago do
          manager = SubscriptionManager.new(subscriber: user)
          manager.subscribe_and_pay_for(create_profile email: 'target3@user.com').tap do
            manager.unsubscribe
          end
        end
      end

      let!(:recently_removed_subscription) do
        Timecop.freeze 26.days.ago do
          manager = SubscriptionManager.new(subscriber: user)
          manager.subscribe_and_pay_for(create_profile email: 'target4@user.com').tap do
            manager.unsubscribe
          end
        end
      end

      let!(:recent_subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create_profile email: 'target@user.com') }

      specify do
        expect(subject.latest_subscriptions.count).to eq(3)
        expect(subject.latest_subscriptions[0][0]).to eq(recent_subscription)
        expect(subject.latest_subscriptions[0][1]).to be_a(ProfileDecorator)
        expect(subject.latest_subscriptions[1][0]).to eq(recently_removed_subscription)
        expect(subject.latest_subscriptions[1][1]).to be_a(ProfileDecorator)
        expect(subject.latest_subscriptions[2][0]).to eq(old_subscription)
        expect(subject.latest_subscriptions[2][1]).to be_a(ProfileDecorator)
      end
    end
  end

  describe '#recent_subscriptions' do
    let(:user) { create_user }

    context 'without subscriptions' do
      specify { expect(subject.recent_subscriptions).to eq([]) }
    end

    context 'with subscriptions' do
      before { StripeMock.start }
      after { StripeMock.stop }

      before do
        UserProfileManager.new(user).update_cc_data(number: '4242424242424242',
                                                    cvc: '333',
                                                    expiry_month: '12',
                                                    expiry_year: 2018,
                                                    address_line_1: 'test',
                                                    zip: '12345',
                                                    city: 'LA',
                                                    state: 'CA')
        user.reload
      end

      let(:active_subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create_profile email: 'target@user.com') }
      let(:rejected_subscription) do
        manager = SubscriptionManager.new(subscriber: user)
        manager.subscribe_and_pay_for(create_profile email: 'target3@user.com').tap do
          manager.reject
        end
      end
      let(:processing_subscription) do
        manager = SubscriptionManager.new(subscriber: user)
        manager.subscribe_and_pay_for(create_profile email: 'target_processig@user.com').tap do
          manager.mark_as_processing
        end
      end
      let(:old_removed_subscription) do
        Timecop.freeze 32.days.ago do
          manager = SubscriptionManager.new(subscriber: user)
          manager.subscribe_and_pay_for(create_profile email: 'target3@user.com').tap do
            manager.unsubscribe
          end
        end
      end
      let(:recently_removed_subscription) do
        Timecop.freeze 26.days.ago do
          manager = SubscriptionManager.new(subscriber: user)
          manager.subscribe_and_pay_for(create_profile email: 'target4@user.com').tap do
            manager.unsubscribe
          end
        end
      end

      it 'returns active subscriptions' do
        expect(subject.recent_subscriptions).to eq([active_subscription])
      end

      it 'does not return rejected subscriptions' do
        expect(subject.recent_subscriptions).not_to eq([rejected_subscription])
      end

      it 'returns processing subscriptions' do
        expect(subject.recent_subscriptions).to eq([processing_subscription])
      end

      it 'returns canceled not expired subscriptions' do
        expect(subject.recent_subscriptions).to eq([recently_removed_subscription])
      end

      it 'does not return canceled expired subscriptions' do
        expect(subject.recent_subscriptions).not_to eq([old_removed_subscription])
      end
    end
  end
end
