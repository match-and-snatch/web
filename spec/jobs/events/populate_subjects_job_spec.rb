require 'spec_helper'

describe Events::PopulateSubjectsJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:subscriber)   { create(:user, email: 'szinin@gmail.com') }
    let(:another_user) { create(:user, :profile_owner, email: 'another@user.com') }
    let(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_to(another_user) }
    let(:event) do
      Event.create! user: subscriber,
                    action: 'subscription_canceled',
                    data: { subscription_id: subscription.id,
                            target_user_id:  subscription.target_user_id }
    end

    it { expect { perform }.not_to raise_error }
    it 'populates subject' do
      expect { perform }.to change { event.reload.subject }.from(nil).to(subscription)
    end
  end
end
