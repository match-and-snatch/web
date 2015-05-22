require 'spec_helper'

describe Api::UsersController, type: :controller do
  describe 'GET #search' do
    let(:user_one) { create_profile_owner first_name: 'sergei', last_name: 'zinin', is_profile_owner: true, profile_name: 'serge zinin', cost: '123.0' }
    let(:user_two) { create_profile_owner first_name: 'serge', last_name: 'zeenin', email: 'serge@zee.ru', is_profile_owner: true }
    let(:user_three) { create_profile_owner first_name: 'dmitry', last_name: 'jakovlev', email: 'dimka@jak.com', is_profile_owner: true }

    subject { get 'search', q: 'serge zi' }

    specify do
      expect(JSON.parse(subject.body)).to include("data" => [
        {
          "access"=>{"owner"=>false, "subscribed"=>false, "billing_failed"=>false},
          "id" => user_one.id,
          "name"=>"serge zinin",
          "slug"=>"sergeizinin",
          "types"=>[],
          "benefits" => [],
          "subscription_cost"=>13407,
          "cost"=>12300,
          "profile_picture_url"=>"set",
          "small_profile_picture_url"=>nil,
          "cover_picture_url"=>nil,
          "cover_picture_position"=>0,
          "downloads_enabled" => true,
          "itunes_enabled" => true,
          "rss_enabled" => false,
          "api_token"=>nil,
          "vacation_enabled" => false,
          "vacation_message" => nil,
          "welcome_media"=>{"welcome_audio"=>{}, "welcome_video"=>{}},
          "dialogue_id"=>nil
        },
        {
          "access"=>{"owner"=>false, "subscribed"=>false, "billing_failed"=>false},
          "id" => user_two.id,
          "name"=>"test",
          "slug"=>"sergezeenin",
          "types"=>[],
          "benefits" => [],
          "subscription_cost"=>2199,
          "cost"=>2000,
          "profile_picture_url"=>"set",
          "small_profile_picture_url"=>nil,
          "cover_picture_url"=>nil,
          "cover_picture_position"=>0,
          "downloads_enabled" => true,
          "itunes_enabled" => true,
          "rss_enabled" => false,
          "api_token"=>nil,
          "vacation_enabled" => false,
          "vacation_message" => nil,
          "welcome_media"=>{"welcome_audio"=>{}, "welcome_video"=>{}},
          "dialogue_id"=>nil
        }
      ])
    end
  end

  describe 'POST #update_profile_name' do
    let(:user) { create_profile_owner api_token: 'set' }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      subject { post 'update_profile_name', id: user.slug, name: 'serezha' }

      its(:status) { is_expected.to eq(200) }
      it { expect { subject }.to change { user.reload.name }.to 'serezha' }
      it { expect(JSON.parse(subject.body)).to include({"data" =>
                                                            {
                                                                "access" => {"owner" => true, "subscribed" => false, "billing_failed" => false},
                                                                "id" => user.id,
                                                                "name" => "serezha",
                                                                "slug" => "sergeizinin",
                                                                "types" => [],
                                                                "benefits" => [],
                                                                "subscription_cost" => 2300,
                                                                "cost" => 2000,
                                                                "profile_picture_url" => "set",
                                                                "small_profile_picture_url"=>nil,
                                                                "cover_picture_url" => nil,
                                                                "cover_picture_position" => 0,
                                                                "downloads_enabled" => true,
                                                                "itunes_enabled" => true,
                                                                "rss_enabled" => false,
                                                                "api_token"=>"set",
                                                                "vacation_enabled" => false,
                                                                "vacation_message" => nil,
                                                                "welcome_media"=>{"welcome_audio"=>{}, "welcome_video"=>{}},
                                                                "dialogue_id"=>nil
                                                            }
                                                       })
      }
    end

    context 'non authorized' do
      subject { post 'update_profile_name', id: user.slug, name: 'serezha' }

      its(:status) { is_expected.to eq(401) }
      it { expect { subject }.not_to change { user.reload.name } }
    end
  end

  describe 'POST #update_profile_picture' do
    let(:user) { create_profile_owner api_token: 'set' }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      subject { post 'update_profile_picture', id: user.slug, transloadit: profile_picture_data_params }

      its(:status) { is_expected.to eq(200) }
      it { expect { subject }.to change { user.reload.profile_picture_url } }
      it { expect(subject.body).to include("data") }
    end

    context 'non authorized' do
      subject { post 'update_profile_picture', id: user.slug }

      its(:status) { is_expected.to eq(401) }
      it { expect { subject }.not_to change { user.reload.profile_picture_url } }
    end
  end

  describe 'POST #update_cost' do
    let(:user) { create_profile_owner api_token: 'set' }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      subject { post 'update_cost', id: user.slug, cost: 10 }

      its(:status) { is_expected.to eq(200) }
      it { expect { subject }.to change { user.reload.cost }.from(2000).to(1000) }
      it { expect(subject.body).to include("data") }
    end

    context 'non authorized' do
      subject { post 'update_cost', id: user.slug, cost: 10 }

      its(:status) { is_expected.to eq(401) }
      it { expect { subject }.not_to change { user.reload.cost } }
    end
  end

  describe 'GET #show' do
    let!(:user) { create_profile email: 'owner@gmail.com', first_name: 'sergei', last_name: 'zinin' }

    subject { get 'show', id: user.slug }

    context 'token is not provided' do
      its(:status) { is_expected.to eq(200) }
      its(:body) { is_expected.to include 'data' }
    end

    context 'token provided' do
      before { sign_in_with_token(token) }

      context 'invalid token' do
        let(:token) { 'invalid' }

        its(:status) { is_expected.to eq(401) }
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
end
