require 'spec_helper'

describe Api::ProfileTypesController, type: :controller do
  let(:user) { create(:user) }

  before { sign_in_with_token(user.api_token) }

  describe 'POST #create' do
    context 'profile type does not exist' do
      subject { post :create, params: {type: 'test'}, format: :json }

      it { is_expected.to be_success }
    end

    context 'profile type does exist' do
      subject { post :create, params: {type: 'test'}, format: :json }

      before { ProfileTypeManager.new.create(title: 'test') }

      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #destroy' do
    context 'profile type does not exist' do
      subject { delete :destroy, params: {id: 1}, format: :json }

      it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
    end

    context 'profile type does exist' do
      subject { delete :destroy, params: {id: profile_type.id}, format: :json }

      let(:profile_type) { ProfileTypeManager.new.create(title: 'test') }

      it { is_expected.to be_success }
    end
  end
end
