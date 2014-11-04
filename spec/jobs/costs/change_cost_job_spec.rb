require 'spec_helper'

describe Costs::ChangeCostJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:profile_owner) { create_profile email: 'profile@user.com' }
    let(:user) { create_user }
    let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(profile_owner) }

    specify { expect { perform }.not_to raise_error }

    context 'update_existing_subscriptions is false' do
      before do
        subscription
        UserProfileManager.new(profile_owner).update_cost(14, update_existing_subscriptions: false)
      end

      it { expect { perform }.not_to change { subscription.reload.cost }.from(500) }

      context 'approved request is presdent' do
        before { CostChangeRequest.last.approve! }

        it { expect { perform }.to change { profile_owner.reload.cost }.from(500).to(1400)  }
      end

      context 'rejected request is present' do
        before { CostChangeRequest.last.reject! }

        it { expect { perform }.not_to change { profile_owner.reload.cost }.from(500)  }
      end
    end

    context 'update_existing_subscriptions is true' do
      before do
        subscription
        UserProfileManager.new(profile_owner).update_cost(14, update_existing_subscriptions: true)
        CostChangeRequest.last.approve!
      end

      it { expect { perform }.to change { subscription.reload.cost }.from(500).to(1400) }
    end
  end
end
