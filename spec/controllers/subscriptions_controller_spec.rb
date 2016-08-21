RSpec.describe SubscriptionsController, type: :controller do
  let(:owner) { create :user, :profile_owner }

  describe 'GET #index' do
    subject { get 'index' }
    its(:status) { is_expected.to eq(401) }

    context 'authorized access' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'GET #new' do
    subject { get :new, params: {user_id: owner.slug} }
    it { is_expected.to be_success }
  end

  describe 'POST #create' do
    before do
      stub_const('Stripe::Customer', double('customer').as_null_object)
    end

    subject { post :create, params: {user_id: owner.slug} }

    its(:status) { is_expected.to eq(401) }

    context 'authorized access' do
      let(:subscriber) { create :subscriber, :with_cc }
      before { sign_in subscriber }

      it { is_expected.to be_success }
    end
  end

  describe 'POST #via_register' do
    before { StripeMock.start }
    after { StripeMock.stop }

    let(:stripe_token) { StripeMock.generate_card_token(number: '4242424242424242') }

    subject { post 'via_register', params: {user_id: owner.slug,
                                            email: 'subscriber@gmail.com',
                                            password: 'gfhjkmqe',
                                            full_name: 'tester tester',
                                            stripe_token: stripe_token,
                                            expiry_month: '12',
                                            expiry_year: '17',
                                            address_line_1: 'Test',
                                            address_line_2: '',
                                            city: 'LA',
                                            state: 'CA',
                                            tos_accepted: 'true',
                                            zip: '123456'} }

    it { is_expected.to be_success }
    its(:body) { is_expected.to match_regex /reload/ }

    context 'with empty stripe token' do
      let(:stripe_token) { }

      it { is_expected.to be_success }
      its(:body) { is_expected.to match_regex /failed/ }
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

  describe 'GET #confirm_restore' do
    let(:user) { create(:user) }
    let(:subscription) { create(:subscription, user: user, target_user: owner) }

    subject { get :confirm_restore, params: {id: subscription.id} }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'PUT #restore' do
    let(:user) { create(:user) }
    let(:subscription) { create(:subscription, user: user, target_user: owner) }

    subject { put :restore, params: {id: subscription.id} }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end
end
