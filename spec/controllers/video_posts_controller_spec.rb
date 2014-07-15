require 'spec_helper'

describe VideoPostsController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }

  describe 'DELETE #cancel' do
    let!(:pending_video) { create_video_upload  owner }
    subject { delete :cancel }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
      its(:body) { should match_regex /success/ }
    end
  end

  describe 'GET #new' do
    subject { get :new }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
    end
  end

  describe 'POST #create' do
    let!(:pending_video) { create_video_upload  owner }
    subject { post :create, title: 'aa', message: 'bb'}

    context 'authorized access' do
      before { sign_in owner }
      its(:status) { should == 200 }
      its(:body) { should match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end
end
