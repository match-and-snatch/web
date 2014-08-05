require 'spec_helper'

describe Billing::ChargeJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    context 'no subscriptions on charge' do
      specify do
        expect { perform }.not_to raise_error
      end
    end

    context 'subscription on charge' do
      before { StripeMock.start }
      after { StripeMock.stop }

      let(:user) { create_user }
      let(:target_user) { create_profile email: 'target@user.com' }

      before do
        UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018)
        user.reload
      end

      let!(:unpaid_subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }
      let!(:paid_subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create_profile email: 'another@one.com') }
      let!(:invalid_subscription) do
        profile = create_profile email: 'invalid@one.com'

        SubscriptionManager.new(subscriber: user).subscribe_to(profile).tap do
          UserProfileManager.new(profile).delete_profile_page
        end
      end

      it 'does not create new subscriptions' do
        expect { perform }.not_to change { Subscription.count }
      end

      it 'creates payment' do
        expect { perform }.to change { Payment.count }.by(1)
      end

      it 'creates payment on unpaid subscription' do
        expect { perform }.to change { unpaid_subscription.payments.count }.by(1)
      end

      it 'changes charge date' do
        expect { perform }.to change { unpaid_subscription.reload.charged_at }
      end

      context 'profile owner on vacation' do
        before do
          UserProfileManager.new(target_user).enable_vacation_mode(reason: 'No reason')
        end

        it 'does not create any payments' do
          expect { perform }.not_to change { unpaid_subscription.payments.count }
        end
      end

      context 'subscriber on vacation' do
        before do
          UserProfileManager.new(user).enable_vacation_mode(reason: 'No reason given')
        end

        it 'creates payment' do
          expect { perform }.to change { unpaid_subscription.payments.count }.by(1)
        end
      end

      context 'having invalid subscription without user set' do
        before do
          subscriber = create_user email: 'invalid@two.com'
          subscription = SubscriptionManager.new(subscriber: subscriber).subscribe_to(target_user)
          subscription.update_attribute(:user_id, nil)
        end

        specify do
          expect { perform }.not_to raise_error
        end
      end
    end
  end
end
