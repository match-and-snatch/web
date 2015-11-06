require 'spec_helper'

describe Queries::Elastic::Profiles do
  describe '#search' do
    subject { described_class.new.search('Test') }

    context 'multiple users' do
      let!(:popular_user) { create(:user, :profile_owner, subscribers_count: 3, profile_name: 'Test') }
      let!(:luser) { create(:user, :profile_owner, subscribers_count: 1, profile_name: 'Test') }

      before { update_index }

      it 'orders records by popularity' do
        expect(subject.records).to eq([popular_user, luser])
      end
    end
  end
end
