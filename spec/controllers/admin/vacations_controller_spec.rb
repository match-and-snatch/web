require 'spec_helper'

describe Admin::VacationsController, type: :controller do
  let(:owner) { create_profile(email: 'profile@gmail.com') }

  describe 'GET #index' do
    subject { get 'index' }

    context 'as an admin' do
      before { sign_in create_admin }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { should_not be_success }
    end
  end

  describe 'GET #history' do
    subject { get 'history', profile_owner_id: owner.id }

    context 'as an admin' do
      before { sign_in create_admin }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create_user }
      it { should_not be_success }
    end
  end
end
