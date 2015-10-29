require 'spec_helper'

describe Api::UsersController, type: :controller do
  describe 'GET #search' do
    let(:user_one) { create_profile_owner first_name: 'sergei', last_name: 'zinin', is_profile_owner: true, profile_name: 'serge zinin', cost: '12.0', hidden: false }
    let(:user_two) { create_profile_owner first_name: 'serge', last_name: 'zeenin', email: 'serge@zee.ru', is_profile_owner: true, hidden: false }
    let(:user_three) { create_profile_owner first_name: 'dmitry', last_name: 'jakovlev', email: 'dimka@jak.com', is_profile_owner: true, hidden: false }

    subject { get 'search', q: 'serge zi', format: :json }

    before do
      user_one
      user_two
    end

    specify do
      expect(JSON.parse(subject.body)).to include("data" => {"results" => [
        {
          "access"=>{"owner"=>false, "subscribed"=>false, "billing_failed"=>false, "public_profile"=>false},
          "id" => user_one.id,
          "name"=>"serge zinin",
          "slug"=>"sergeizinin",
          "picture_url"=>nil,
          "has_profile"=>true,
          "downloads_enabled" => true,
          "itunes_enabled" => true,
          "types"=>[],
          "benefits" => [],
          "subscription_cost"=>1399,
          "cost"=>1200,
          "profile_picture_url"=>"set",
          "small_profile_picture_url"=>nil,
          "cover_picture_url"=>nil,
          "cover_picture_position"=>0,
          "cover_picture_position_perc"=>0.0,
          "cover_picture_height"=>nil,
          "rss_enabled" => true,
          "vacation_enabled" => false,
          "vacation_message" => nil,
          "contributions_enabled"=>false,
          "has_mature_content"=>false,
          "welcome_media"=>{"welcome_audio"=>{}, "welcome_video"=>{}},
          "custom_welcome_message"=>nil,
          "special_offer_message"=>nil,
          "locked"=>false,
          "cost_approved"=>true,
          "dialogue_id"=>nil
        },
        {
          "access"=>{"owner"=>false, "subscribed"=>false, "billing_failed"=>false, "public_profile"=>false},
          "id" => user_two.id,
          "name"=>"test",
          "slug"=>"sergezeenin",
          "picture_url"=>nil,
          "has_profile"=>true,
          "downloads_enabled" => true,
          "itunes_enabled" => true,
          "types"=>[],
          "benefits" => [],
          "subscription_cost"=>2300,
          "cost"=>2000,
          "profile_picture_url"=>"set",
          "small_profile_picture_url"=>nil,
          "cover_picture_url"=>nil,
          "cover_picture_position"=>0,
          "cover_picture_position_perc"=>0.0,
          "cover_picture_height"=>nil,
          "rss_enabled" => true,
          "vacation_enabled" => false,
          "vacation_message" => nil,
          "contributions_enabled"=>false,
          "has_mature_content"=>false,
          "welcome_media"=>{"welcome_audio"=>{}, "welcome_video"=>{}},
          "custom_welcome_message"=>nil,
          "special_offer_message"=>nil,
          "locked"=>false,
          "cost_approved"=>true,
          "dialogue_id"=>nil
        }
      ]})
    end
  end

  describe 'POST #update_profile_name' do
    let(:user) { create_profile_owner api_token: 'set', hidden: false }

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
    let(:user) { create_profile_owner api_token: 'set', hidden: false }

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
    let(:user) { create_profile_owner api_token: 'set', hidden: false }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      subject { post 'update_cost', id: user.slug, cost: 10, format: :json }

      its(:status) { is_expected.to eq(200) }
      it { expect { subject }.to change { user.reload.cost }.from(2000).to(1000) }
      it { expect(subject.body).to include("data") }
    end

    context 'non authorized' do
      subject { post 'update_cost', id: user.slug, cost: 10, format: :json }

      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      it { expect { subject }.not_to change { user.reload.cost } }
    end
  end

  describe 'GET #show' do
    let!(:user) { create_profile email: 'owner@gmail.com', first_name: 'sergei', last_name: 'zinin' }

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
        let(:api_user) { create_user email: 'api@user.ru', api_token: 'test_token' }
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
end
