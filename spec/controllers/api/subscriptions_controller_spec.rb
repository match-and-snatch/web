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

    subject { post 'create', user_id: owner.slug, format: :json }

    it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }

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
                   zip: '123456',
                   format: :json }

    it { should be_success }
    its(:body) { should match_regex /success/ }

    context 'with failed payment' do
      let(:card_number) { '4000000000000341' }

      it { should be_success }
      its(:body) { should match_regex /success/ }
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

  describe 'GET #search_subscribers' do
    pending
  end
end
