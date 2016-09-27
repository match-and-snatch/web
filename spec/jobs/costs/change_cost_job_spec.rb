describe Costs::ChangeCostJob do
  describe '.perform' do
    subject(:perform) { described_class.new.perform }

    let(:profile_owner) { create(:user, :profile_owner, email: 'profile@user.com', cost: 5_00) }
    let(:user) { create(:user) }
    let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(profile_owner) }

    it { expect { perform }.not_to raise_error }
    it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Change Cost Job/) }

    context 'update_existing_subscriptions is false' do
      before do
        subscription
        UserProfileManager.new(profile_owner).update_cost(14, update_existing_subscriptions: false)
      end

      it { expect { perform }.not_to change { subscription.reload.cost }.from(500) }

      context 'approved request is present' do
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
