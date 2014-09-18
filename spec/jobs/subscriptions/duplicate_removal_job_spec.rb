require 'spec_helper'

describe Subscriptions::DuplicateRemovalJob do
  describe '#perform' do
    subject(:perform) { described_class.perform }

    before { StripeMock.start }
    after { StripeMock.stop }

    before do
      UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018)
    end

    let(:user) { create_user }
    let(:target_user) { create_profile email: 'target@user.com' }
    let(:another_target_user) { create_profile email: 'another_target@user.com' }

    let!(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user) }

    context 'with duplicates' do
      let!(:duplicate) do
        tmp_subscription = SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(another_target_user)
        tmp_subscription.target_user = target_user
        tmp_subscription.save
        tmp_subscription
      end

      specify do
        expect { perform }.to change { user.subscriptions.count }.from(2).to(1)
      end

      specify do
        expect { perform }.to change { subscription.payments.count }.from(1).to(2)
      end

      context 'duplicate is canceled' do
        before do
          duplicate.remove!
        end

        specify do
          expect { perform }.to change { user.subscriptions.count }.from(2).to(1)
        end

        specify do
          expect { perform }.to change { subscription.payments.count }.from(1).to(2)
        end
      end
    end

    context 'without duplicates' do
      it 'nothing changes' do
        expect { perform }.not_to change { user.subscriptions.count }
        expect { perform }.not_to change { subscription.payments.count }
        expect { perform }.not_to change { subscription.payment_failures.count }
      end
    end
  end
end