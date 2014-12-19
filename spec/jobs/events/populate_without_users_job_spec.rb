require 'spec_helper'

describe Events::PopulateWithoutUsersJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:user) { create_user }
    let(:target_user) { create_profile email: 'target@user.com' }

    before { StripeMock.start }
    after { StripeMock.stop }

    before do
      user.events.delete_all
      target_user.events.delete_all

      user.reload
    end

    specify { expect { perform }.not_to raise_error }

    context 'subscription without user' do
      before do
        UserProfileManager.new(user).update_cc_data(number: '4242_4242_4242_4242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
        SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user)

        user.events.delete_all
        user.delete
      end

      specify { expect { perform }.to change { user.events.where(action: 'subscription_created').count }.from(0).to(1) }
      specify { expect { perform }.to change { user.events.where(action: 'subscription_canceled').count }.from(0).to(1) }
      specify { expect { perform }.to change { Subscription.count }.from(1).to(0) }
    end

    context 'canceled subscription' do
      before do
        UserProfileManager.new(user).update_cc_data(number: '4242_4242_4242_4242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
        SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user)
        SubscriptionManager.new(subscription: user.subscriptions.last).unsubscribe

        user.events.delete_all
      end

      specify { expect { perform }.to change { user.events.where(action: 'subscription_canceled').count }.from(0).to(1) }
    end
  end
end
