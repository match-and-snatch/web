require 'spec_helper'

describe TopProfile do
  describe '.update_list' do
    let(:user1) { create(:user, email: '1@1.ru') }
    let(:user2) { create(:user, email: '2@2.ru') }

    before do
      user1.create_top_profile!
      user2.create_top_profile!
    end

    before { described_class.update_list user_ids }
    let(:user_ids) { [] }

    it 'does not change positions' do
      top_profiles = TopProfile.all
      expect(top_profiles.where(user_id: user1).first.position).to eq(0)
      expect(top_profiles.where(user_id: user2).first.position).to eq(0)
    end

    context 'user_ids is not empty' do
      let(:user_ids) { [user1.id, user2.id] }

      it 'fills the list with user ids' do
        top_profiles = TopProfile.all
        expect(top_profiles.where(user_id: user1).first.position).to eq(0)
        expect(top_profiles.where(user_id: user2).first.position).to eq(1)
      end
    end
  end

  describe '#profile_types_text=' do
    context 'whitespaces around' do
      before do
        subject.profile_types_text = " truncate me please   "
      end

      its(:profile_types_text) { is_expected.to eq("truncate me please") }

      context 'after save' do
        before do
          subject.save!
          subject.reload
        end

        its(:profile_types_text) { is_expected.to eq("truncate me please") }
      end
    end

    context 'nil given' do
      before { subject.profile_types_text = nil }
      its(:profile_types_text) { is_expected.to eq(nil) }
    end

    context 'no whitespaces around' do
      before do
        subject.profile_types_text = "truncate me please"
      end

      its(:profile_types_text) { is_expected.to eq("truncate me please") }
    end
  end
end
