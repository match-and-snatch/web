require 'spec_helper'

describe SubscriptionsController, type: :controller do
  let(:owner) do
    create_user.tap do |user|
      UserProfileManager.new(user).create_profile_page
      UserProfileManager.new(user).update cost:           10,
                                          profile_name:   'profile name',
                                          holder_name:    'Sergei Zinin',
                                          routing_number: '123456789',
                                          account_number: '000123456789'
    end
  end

  describe 'GET #index' do
    subject { get 'index' }
    its(:status) { should eq(401) }

    context 'authorized access' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'GET #new' do
    subject { get 'new', user_id: owner.slug }
    it { should be_success }
  end

  describe 'POST #create' do
    before do
      stub_const('Stripe::Customer', double('customer').as_null_object)
    end

    subject { post 'create', user_id: owner.slug }

    its(:status) { should eq(401) }

    context 'authorized access' do
      let(:subscriber) do
        create_user(email: 'subscriber@gmail.com').tap do |user|
          UserProfileManager.new(user).update_cc_data(number: '4242424242424242',
                                                      cvc: '123',
                                                      expiry_month: '12',
                                                      expiry_year: '15',
                                                      address_line_1: 'test',
                                                      zip: '12345',
                                                      city: 'LA',
                                                      state: 'CA')
        end
      end

      before { sign_in subscriber }

      it { should be_success }
    end
  end

  describe 'POST #via_register' do
    before { StripeMock.start }
    after { StripeMock.stop }

    let(:card_number) { '4242424242424242' }

    subject { post 'via_register', user_id: owner.slug,
                                   email: 'subscriber@gmail.com',
                                   password: 'gfhjkmqe',
                                   full_name: 'tester tester',
                                   number: card_number,
                                   cvc: '123',
                                   expiry_month: '12',
                                   expiry_year: '17',
                                   address_line_1: '',
                                   address_line_2: '',
                                   city: '',
                                   state: '',
                                   zip: '' }

    it { should be_success }
    its(:body) { should match_regex /reload/ }

    context 'with failed payment' do
      let(:card_number) { '4000000000000341' }

      it { should be_success }
      its(:body) { should match_regex /reload/ }
    end

    # TODO : WHY IT DOESN'T WORK?
    # context 'with declined card' do
    #   before { StripeMock.prepare_card_error(:card_declined, :new_customer) }
    #
    #   let(:card_number) { '4000000000000002' }
    #
    #   it { should be_success }
    #   its(:body) { should match_regex /failed/ }
    # end
  end
end
