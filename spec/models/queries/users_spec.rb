describe Queries::Users do
  let(:performer) { create(:user, email: 'performer@gmail.com') }
  let!(:first_user) { create(:user, :profile_owner, email: 'szinin@gmail.com', full_name: 'Sergei', profile_name: 'Sergei Zinin') }
  let!(:second_user) { create(:user, :with_cc, email: 'spopov@gmail.com', full_name: 'Slava') }
  let(:query) { 'szinin@gmail.com' }

  subject { described_class.new(user: performer, query: query) }

  before { update_index }

  describe '#grouped_by_first_letter' do
    it { expect(subject.grouped_by_first_letter).to include({ 'S' => [first_user] }) }
  end

  describe '#by_first_letter' do
    it { expect(subject.by_first_letter).to eq([first_user]) }
  end

  describe '#by_name' do
    let(:query) { 'sergei' }

    it { expect(subject.by_name).to eq([first_user]) }
  end

  describe '#by_admin_fields' do
    context 'query is a stripe user id' do
      let(:query) { second_user.stripe_user_id }

      it { expect(subject.by_admin_fields).to eq([second_user]) }
    end

    context 'query is an email' do
      it { expect(subject.by_admin_fields).to eq([first_user]) }
    end

    context 'query is an id' do
      let(:query) { second_user.id }

      it { expect(subject.by_admin_fields).to eq([second_user]) }
    end

    context 'regular query' do
      let(:query) { 'Slava' }

      it { expect(subject.by_admin_fields).to eq([second_user]) }
    end
  end

  describe '#potential_partners' do
    pending
  end

  describe '#profile_owners_by_text' do
    context 'empty query' do
      let(:query) { '' }

      it { expect(subject.profile_owners_by_text).to eq([]) }
    end

    context 'short query' do
      let(:query) { 's' }

      it { expect(subject.profile_owners_by_text).to eq([]) }
    end

    context 'normal query' do
      let(:query) { 'Sergei' }

      it { expect(subject.profile_owners_by_text).to eq([first_user]) }
    end
  end

  describe '#by_email' do
    it { expect(subject.by_email).to eql([first_user]) }
  end

  describe '#by_tos_acceptance' do
    let!(:accepted_tos_user) { create(:user, tos_accepted: true) }
    let!(:not_accepted_tos_user) { create(:user, tos_accepted: false) }

    let(:query) { nil }
    it { expect(subject.by_tos_acceptance).to match_array([accepted_tos_user, performer, first_user, second_user]) }

    context 'invalid query' do
      let(:query) { 'ivalid' }
      it { expect { subject.by_tos_acceptance }.to raise_error(ArgumentError) }
    end

    context 'query is "accepted"' do
      let(:query) { 'accepted' }
      it { expect(subject.by_tos_acceptance).to match_array([accepted_tos_user, performer, first_user, second_user]) }
    end

    context 'query is "not_accepted"' do
      let(:query) { 'not_accepted' }
      it { expect(subject.by_tos_acceptance).to eq([not_accepted_tos_user]) }
    end

    context 'query is "by_admin"' do
      let(:query) { 'by_admin' }
      let(:user) { create(:user, tos_accepted: true) }

      before do
        create(:tos_version, :published)
        UserManager.new(user, create(:user, :admin)).mark_tos_accepted(accepted: true)
      end

      it { expect(subject.by_tos_acceptance).to eq([user]) }
    end
  end
end
