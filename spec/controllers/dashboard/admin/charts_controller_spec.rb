require 'spec_helper'

describe Dashboard::Admin::ChartsController, type: :controller do
  describe 'GET #index' do
    subject { get 'index' }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { should_not be_success }
    end
  end

  describe 'GET #show' do
    subject { get :show, params: {id: 'some_id'} }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { should_not be_success }
    end
  end
end
