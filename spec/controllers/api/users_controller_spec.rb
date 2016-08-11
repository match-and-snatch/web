require 'spec_helper'

describe Api::UsersController, type: :controller do
  describe 'GET #search' do
    let!(:match_1) { create :user, :profile_owner, full_name: 'serge zinin', profile_name: 'serge zinin', subscribers_count: 100 }
    let!(:match_2) { create :user, :profile_owner, full_name: 'serge zinin', profile_name: 'sergei zinin', subscribers_count: 5 }
    let!(:miss) { create :user, :profile_owner, full_name: 'dimka jakovlev', profile_name: 'dimka' }

    before { update_index }

    subject { get 'search', q: 'serge', format: :json }
    let(:results) { JSON.parse(subject.body)['data']['results'] }

    specify do
      expect(results.count).to eq(2)
      expect(results.first['id']).to eq(match_1.id)
      expect(results.second['id']).to eq(match_2.id)
    end
  end

  describe 'POST #update_profile_name' do
    let(:user) { create :user, :profile_owner, api_token: 'set' }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      subject { post 'update_profile_name', id: user.slug, name: 'serezha', format: :json }

      its(:status) { is_expected.to eq(200) }
      it { expect { subject }.to change { user.reload.name }.to 'serezha' }

      specify do
        expect(JSON.parse(subject.body)).to include({
          "data" => {"profile_name" => "serezha"},
          "api_token" => nil,
          "status" => "success",
        })
      end

      specify do
        expect(JSON.parse(subject.body)).to have_key('token')
      end
    end

    context 'non authorized' do
      subject { post 'update_profile_name', id: user.slug, name: 'serezha', format: :json }

      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      it { expect { subject }.not_to change { user.reload.name } }
    end
  end

  describe 'POST #update_profile_picture' do
    let(:user) { create :user, :profile_owner, api_token: 'set' }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      subject { post 'update_profile_picture', id: user.slug, transloadit: profile_picture_data_params.to_json, format: :json }

      its(:status) { is_expected.to eq(200) }
      it { expect { subject }.to change { user.reload.profile_picture_url } }
      it { expect(subject.body).to include("data") }
    end

    context 'non authorized' do
      subject { post 'update_profile_picture', id: user.slug, format: :json }

      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      it { expect { subject }.not_to change { user.reload.profile_picture_url } }
    end
  end

  describe 'POST #update_cost' do
    let(:user) { create :user, :profile_owner, api_token: 'set' }
    let(:cost) { 5 }

    subject { post 'update_cost', id: user.slug, cost: cost, format: :json }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      its(:status) { is_expected.to eq(200) }
      it { expect { subject }.to change { user.reload.cost }.to(5_00) }
      it { expect(subject.body).to include("data") }

      context 'large cost' do
        let(:cost) { 6 }

        its(:status) { is_expected.to eq(200) }
        it { expect { subject }.not_to change { user.reload.cost } }
        it { expect(JSON.parse(subject.body)).to include({"notice"=>/Your price change request has been submitted/}) }
      end
    end

    context 'non authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      it { expect { subject }.not_to change { user.reload.cost } }
    end
  end

  describe 'GET #show' do
    let!(:user) { create(:user, :profile_owner, email: 'owner@gmail.com', full_name: 'sergei zinin') }

    subject { get 'show', id: user.slug, format: :json }

    context 'token is not provided' do
      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to include 'data' }
    end

    context 'token provided' do
      before { sign_in_with_token(token) }

      context 'invalid token' do
        let(:token) { 'invalid' }

        its(:status) { is_expected.to eq(200) }
        its(:body) { is_expected.to include 'failed' }
      end

      context 'valid token' do
        let(:api_user) { create :user, email: 'api@user.ru', api_token: 'test_token' }
        let(:token) { api_user.api_token }

        its(:status) { is_expected.to eq(200) }
        its(:body) { is_expected.to include 'success' }
        its(:body) { is_expected.to include 'data' }
      end
    end
  end

  describe 'GET #fetch_current_user' do
    subject { get 'fetch_current_user', format: :json }

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to include 'success' }
    its(:body) { is_expected.to include 'data' }
  end

  describe 'POST #login_as' do
    let(:another_user) { create(:user, :profile_owner) }
    let(:user) { create(:user) }

    subject { post 'login_as', id: another_user.slug, format: :json }

    before { sign_in_with_token(user.api_token) }

    it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }

    context 'user is admin' do
      let(:user) { create(:user, :admin) }

      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to include 'success' }
      its(:body) { is_expected.to include 'data' }
    end
  end
end
