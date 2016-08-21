require 'spec_helper'

describe PhotosController, type: :controller do
  let(:owner) { create :user, email: 'owner@gmail.com', is_profile_owner: true }

  describe 'GET #show' do
    let!(:photo) { UploadManager.new(owner).create_pending_photos(transloadit_photo_data_params).first }
    let(:_post) { PostManager.new(user: owner).create_photo_post(title: 'test', message: 'test') }

    subject { get :show, params: {id: photo.id} }

    context 'authorized access' do
      before { sign_in owner }

      it { is_expected.to be_success }

      context 'removed post' do
        before do
          PostManager.new(user: owner).delete(_post)
        end

        it { is_expected.to be_success }
      end
    end
  end

  describe 'GET #profile_picture' do
    subject { get :profile_picture, params: {user_id: owner.slug} }

    context 'unauthorized access' do
      it { is_expected.to be_success }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #cover_picture' do
    subject { get :cover_picture, params: {user_id: owner.slug} }

    context 'unauthorized access' do
      it { is_expected.to be_success }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
    end
  end

  describe 'POST #create' do
    subject { post :create, params: {transloadit: transloadit_photo_data_params.to_json} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      its(:body) { is_expected.to match_regex /replace/ }
      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #destroy' do
    let(:photo_upload) { create(:photo, user: owner) }
    subject { delete :destroy, params: {id: photo_upload.id} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      before { sign_in owner }
      it { is_expected.to be_success }
    end
  end
end
