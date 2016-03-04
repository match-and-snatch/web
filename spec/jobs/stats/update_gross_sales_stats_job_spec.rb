require 'spec_helper'

describe Stats::UpdateGrossSalesStatsJob do
  subject(:perform) { described_class.perform }

  let(:user) { create(:user, :with_cc) }
  let(:target_user) { create(:user, :profile_owner) }

  before { StripeMock.start }
  after { StripeMock.stop }

  before do
    SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user)
  end

  it { expect(target_user.gross_sales).to eq(499) }

  describe '.perform' do
    before { target_user.update_attribute(:gross_sales, 123) }

    it { expect { perform }.to change { target_user.reload.gross_sales }.from(123).to(499) }
  end
end
