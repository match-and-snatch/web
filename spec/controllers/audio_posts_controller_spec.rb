require 'spec_helper'

describe AudioPostsController, type: :controller do
  let(:owner) { create :user, email: 'owner@gmail.com', is_profile_owner: true }

  describe 'GET #new' do
    subject { get :new, format: :json }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
    end
  end

  describe 'DELETE #cancel' do
    subject { delete :cancel }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
      its(:body) { should match_regex /success/ }
    end
  end

  describe 'POST #create' do
    subject { post :create, title: 'audio', message: 'post', format: :json }

    context 'authorized access' do
      before do
        sign_in owner
        create(:audio, :pending, user: owner)
      end

      it { should be_success }
      its(:body) { should match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end
end
