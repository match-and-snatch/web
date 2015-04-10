require 'spec_helper'

describe Api::PhotoPostsController, type: :controller do
  let(:owner) { create_user email: 'owner@gmail.com', is_profile_owner: true, api_token: 'token' }

  describe 'DELETE #cancel' do
    subject { delete :cancel }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'GET #new' do
    subject { get :new }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { should be_success }
    end
  end

  describe 'POST #create' do
    subject { post :create, title: 'photo', message: 'post' }

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      let!(:pending_photo) { create_photo_upload(owner).first }

      it { should be_success }
    end

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end
  end
end
