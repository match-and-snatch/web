require 'spec_helper'

describe Contribution do
  describe '.to_charge' do
    subject { described_class.to_charge }

    let(:contribution_to_user_with_profile_page) { create :contribution, recurring: true, target_user: create(:user, :profile_owner), updated_at: 100.years.ago }
    let(:contribution_to_user_without_profile_page) { create :contribution, recurring: true, target_user: create(:user), updated_at: 100.years.ago }

    it { is_expected.to include(contribution_to_user_with_profile_page) }
    it { is_expected.not_to include(contribution_to_user_without_profile_page) }
  end
end
