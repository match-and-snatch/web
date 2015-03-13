require 'spec_helper'

describe TopProfile do
  describe '.update_list' do
    let(:user1) { create_user email: '1@1.ru' }
    let(:user2) { create_user email: '2@2.ru' }

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
end
