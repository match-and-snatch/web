require 'spec_helper'

describe Api::SubscriptionsController, type: :controller do
  let(:owner) do
    create_user(api_token: 'owner_token').tap do |user|
      UserProfileManager.new(user).create_profile_page
      UserProfileManager.new(user).update cost:           10,
                                          profile_name:   'profile name',
                                          holder_name:    'Sergei Zinin',
                                          routing_number: '123456789',
                                          account_number: '000123456789'
    end
  end

  describe 'POST #create' do
    before do
      stub_const('Stripe::Customer', double('customer').as_null_object)
    end

    subject { post 'create', user_id: owner.slug }

    its(:status) { should eq(401) }

    context 'authorized access' do
      let(:subscriber) do
        create_user(email: 'subscriber@gmail.com', api_token: 'subscriber_token').tap do |user|
          UserProfileManager.new(user).update_cc_data number: '4242424242424242',
                                                      cvc: '123',
                                                      expiry_month: '12',
                                                      expiry_year: '15',
                                                      address_line_1: 'test',
                                                      zip: '12345',
                                                      city: 'LA',
                                                      state: 'CA'
        end
      end

      before { sign_in_with_token subscriber.api_token }

      it { should be_success }
    end
  end

  describe 'PUT #enable_notifications' do
    pending
  end

  describe 'PUT #disable_notifications' do
    pending
  end

  describe 'PUT #restore' do
    pending
  end

  describe 'DELETE #destroy' do
    pending
  end
end
