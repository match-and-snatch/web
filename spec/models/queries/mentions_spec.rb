describe Queries::Mentions do
  let(:current_user) { create :user, :with_cc, full_name: 'Dmitry' }
  let(:profile_owner) { create :user, :profile_owner, profile_name: 'Andy' }
  let(:subscriber) { create :user, full_name: 'Sasha Gray' }

  before do
    SubscriptionManager.new(subscriber: subscriber).subscribe_to(profile_owner)
    SubscriptionManager.new(subscriber: current_user).subscribe_to(profile_owner)
    update_index
  end

  subject(:query) { described_class.new(query: q, current_user: current_user, profile_id: profile_owner.id)  }

  describe '#by_name' do
    subject(:results) { query.by_name }

    context 'query is too short' do
      let(:q) { 'A' }
      it { is_expected.to be_empty }
    end

    context 'as a subscriber' do
      context 'querying profile owner' do
        let(:q) { 'Andy' }
        it { is_expected.to eq([profile_owner]) }
      end

      context 'querying another subscriber' do
        let(:q) { 'Sasha' }
        it { is_expected.to eq([subscriber]) }
      end

      context 'querying self' do
        let(:q) { 'Dmitry' }
        it { is_expected.to be_empty }
      end
    end

    context 'as a profile owner' do
      subject(:results) { described_class.new(query: q, current_user: profile_owner, profile_id: profile_owner.id).by_name  }

      context 'querying profile owner' do
        let(:q) { 'Andy' }
        it { is_expected.to be_empty }
      end

      context 'querying another subscriber' do
        let(:q) { 'Sasha' }
        it { is_expected.to eq([subscriber]) }
      end

      context 'querying self' do
        let(:q) { 'Dmitry' }
        it { is_expected.to eq([current_user]) }
      end

      context 'querying after subscription' do
        let(:another_user) { create :user, :with_cc, full_name: 'Donald' }

        before do
          SubscriptionManager.new(subscriber: another_user).subscribe_to(profile_owner)
          sleep 1
        end

        let(:q) { 'Donald' }
        it { is_expected.to eq([another_user]) }
      end
    end
  end
end
