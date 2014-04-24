require 'spec_helper'

describe AudioPostsController do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true }

  describe 'DELETE #cancel' do
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
    subject { post :create, title: 'aa', message: 'bb'}

    context 'authorized access' do
      before { sign_in owner }
      let!(:pending_audio) { create_audios_upload(owner).first }

      its(:status) { should == 200 }
      its(:body) { should match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end
end