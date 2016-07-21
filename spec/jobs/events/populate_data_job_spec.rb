require 'spec_helper'

describe Events::PopulateDataJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:user)   { create(:user) }
    let(:subscription) { create(:subscription, user: user) }
    let(:data) { { subscription_id: subscription.id, target_user_id:  subscription.target_user_id } }
    let(:event) do
      Event.create! user: user, action: 'subscription_canceled', old_data: data.to_yaml
    end

    it { expect { perform }.not_to raise_error }
    it 'populates data' do
      expect { perform }.to change { event.reload.data }.from({}).to(data)
    end
  end
end
