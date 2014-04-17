require 'spec_helper'

describe SubscriptionsController do
  let(:owner) {
    create_user.tap do |user|
      UserProfileManager.new(user).create_profile_page
      UserProfileManager.new(user).update(cost: 10, profile_name: 'profile name')
      UserProfileManager.new(user).update_payment_information holder_name:    'Sergei Zinin',
                                                              routing_number: '123456789',
                                                              account_number: '000123456789'
    end
  }

  describe 'GET #index' do
    subject { get 'index' }
    its(:status) { should == 401 }

    context 'authorized access' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'GET #new' do
    subject { get 'new', user_id: owner.slug }
    its(:status) { should == 200 }
  end

  describe 'POST #create' do
    before do
      stub_const('Stripe::Customer', double('customer').as_null_object)
    end

    subject { post 'create', user_id: owner.slug }

    its(:status) { should == 401 }

    context 'authorized access' do
      let(:subscriber) do
        create_user(email: 'subscriber@gmail.com').tap do |user|
          UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '123', expiry_month: '12', expiry_year: '15')
        end
      end

      before { sign_in subscriber }

      its(:status) { should == 200 }
    end
  end

  describe 'POST #via_register' do
    before do
      stub_const('Stripe::Customer', double('customer').as_null_object)
      stub_const('Stripe::Charge', double('charge').as_null_object)
    end

  end
end