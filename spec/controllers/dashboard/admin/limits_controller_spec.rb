require 'spec_helper'

describe Dashboard::Admin::LimitsController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET #search' do
    subject { get 'search', q: 'query' }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { should_not be_success }
    end
  end

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

  describe 'GET #edit' do
    subject { get 'edit', id: user.id }

    context 'as an admin' do
      before { sign_in create(:user, :admin) }
      it { should be_success }
    end

    context 'as a non admin' do
      before { sign_in create(:user) }
      it { should_not be_success }
    end
  end

  describe 'PATCH #update' do
    subject { patch 'update', id: user.id, limit: 10 }

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
