describe Queries::Recipients do
  let(:owner) { create(:user, :profile_owner, profile_name: 'Owner') }
  let(:performer) { create(:user, email: 'performer@gmail.com') }
  let(:query) { '' }
  let!(:subscription) { create(:subscription, user: performer, target_user: owner) }

  subject { described_class.new(user: performer, query: query) }


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

      context 'deleted subscription' do
        let!(:subscription) { create(:subscription, :deleted, user: performer, target_user: owner) }

        it { expect(subject.by_name).to eq([]) }
      end
    end
  end
end
