require 'spec_helper'

describe Api::SubscriptionsController, type: :controller do
  let(:owner) { create :user, :profile_owner }

  describe 'POST #create' do
    before do
      stub_const('Stripe::Customer', double('customer').as_null_object)
    end

    subject { post :create, params: {user_id: owner.slug}, format: :json }

    it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }

    context 'authorized access' do
      let(:subscriber) { create :subscriber, :with_cc }

      before { sign_in_with_token subscriber.api_token }

      it { is_expected.to be_success }
    end
  end

  describe 'POST #via_register' do
    before { StripeMock.start }
    after { StripeMock.stop }

    let(:stripe_token) { StripeMock.generate_card_token(number: '4242424242424242') }
    let(:email) { 'subscriber@gmail.com' }
    let(:email_confirmation) { 'subscriber@gmail.com' }

    subject { post 'via_register', params: {user_id: owner.slug,
                                            email: email,
                                            email_confirmation: email_confirmation,
                                            password: 'gfhjkmqe',
                                            full_name: 'tester tester',
                                            stripe_token: stripe_token,
                                            expiry_month: '12',
                                            expiry_year: '17',
                                            address_line_1: 'Test',
                                            address_line_2: '',
                                            city: 'LA',
                                            state: 'CA',
                                            zip: '123456',
                                            tos_accepted: 'true'}, format: :json }

    it { is_expected.to be_success }
    its(:body) { is_expected.to match_regex /success/ }

    context 'with failed payment' do
      let(:card_number) { '4000000000000341' }

      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /success/ }
    end

    context 'with wrong confirmation email' do
      let(:email_confirmation) { 'wrong@gmail.com' }

      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex(/failed/) }
    end

    # TODO : WHY IT DOESN'T WORK?
    # context 'with declined card' do
    #   before { StripeMock.prepare_card_error(:card_declined, :new_customer) }
    #
    #   let(:card_number) { '4000000000000002' }
    #
    #   it { is_expected.to be_success }
    #   its(:body) { is_expected.to match_regex /failed/ }
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
