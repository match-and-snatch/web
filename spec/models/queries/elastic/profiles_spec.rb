require 'spec_helper'

describe Queries::Elastic::Profiles do
  subject { described_class.new }

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

  describe '#delete', focus: true do
    let!(:popular_user) { create(:user, :profile_owner, subscribers_count: 3, profile_name: 'Test') }
    let!(:luser) { create(:user, :profile_owner, subscribers_count: 1, profile_name: 'Test') }

    before do
      update_index
      sleep 5
      subject.delete
      sleep 5
      refresh_index
      sleep 5
    end

    it { expect(subject.search('Test').records).to eq([]) }
  end

  describe '#client' do
    it { expect(subject.client).to be_a(Elasticpal::Client) }
  end

  describe '#index' do
    it { expect(subject.index).to eq('users') }
  end

  describe '#model' do
    pending
  end

  describe '#scope' do
    pending
  end

  describe '#type' do
    it { expect(subject.type).to eq('profiles') }
  end
end
