require 'spec_helper'

describe Queries::Recipients do
  let(:owner) { create(:user, :profile_owner, profile_name: 'Owner') }
  let(:performer) { create(:user, email: 'performer@gmail.com') }
  let(:query) { '' }

  subject { described_class.new(user: performer, query: query) }

  before { SubscriptionManager.new(subscriber: performer).subscribe_to(owner) }

  describe '#by_name' do
    context 'empty query' do
      it { expect(subject.by_name).to eq([]) }
    end

    context 'short query' do
      let(:query) { 'ow' }

      it { expect(subject.by_name).to eq([owner]) }
    end

    context 'normal query' do
      let(:query) { 'owner' }

      before { update_index owner }

      it { expect(subject.by_name).to eq([owner]) }
    end
  end
end
