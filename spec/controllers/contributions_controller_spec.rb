require 'spec_helper'

describe ContributionsController, type: :controller do
  let(:user) { create(:user) }
  let(:target_user) { create(:user, :profile_owner) }

  describe 'GET #new' do
    subject { get 'new', target_user_id: target_user.id }

    context 'authorized' do
      before { sign_in user }
      its(:status) { should eq(200) }
    end

    context 'non authorized' do
      its(:status) { should eq(200) }
    end

    context 'request without target_user_id' do
      subject { get 'new' }
      its(:status) { should eq(200) }
    end
  end
end
