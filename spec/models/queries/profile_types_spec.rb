require 'spec_helper'

describe Queries::ProfileTypes do
  subject { described_class.new user: user, query: 'match' }

  let(:user) { create(:user) }
  let!(:matching_profile_type) { ProfileTypeManager.new.create(title: 'matching') }
  let!(:not_mathing_profile_type) { ProfileTypeManager.new.create(title: 'something really different') }
  let!(:user_matching_profile_type) do
    ProfileTypeManager.new.create(title: 'matching user').tap do |profile_type|
      UserProfileManager.new(user).add_profile_type(profile_type.title)
    end
  end

  its(:results) { is_expected.to eq([matching_profile_type]) }
end
