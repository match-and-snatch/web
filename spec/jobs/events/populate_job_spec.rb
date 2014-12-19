require 'spec_helper'

describe Events::PopulateJob do
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

    specify do
      expect { perform }.not_to raise_error
    end
    specify do
      expect { perform }.to change { user.events.where(action: 'registered').count }.from(0).to(1)
    end
    specify do
      expect { perform }.to change { user.events.where(action: 'logged_in').count }.from(0).to(1)
    end
    specify do
      expect { perform }.to change { target_user.events.where(action: 'profile_created').count }.from(0).to(1)
    end

    context 'with subscriptions' do
      before do
        UserProfileManager.new(user).update_cc_data(number: '4242_4242_4242_4242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
        SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user)

        user.events.delete_all
        user.reload
      end

      specify  do
        expect { perform }.to change { user.events.where(action: 'credit_card_updated').count }.from(0).to(1)
      end
      specify  do
        expect { perform }.to change { user.events.where(action: 'subscription_created').count }.from(0).to(1)
      end
      specify  do
        expect { perform }.to change { user.events.where(action: 'payment_created').count }.from(0).to(1)
      end
    end
  end
end