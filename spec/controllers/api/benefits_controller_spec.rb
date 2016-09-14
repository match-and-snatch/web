describe Api::BenefitsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:benefits_params) {  {"0"=>"benefit", "1"=>"other benefit", "2"=>""} }

    subject(:perform_request) { post :create, params: {user_id: user.id, benefits: benefits_params}, format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before do
        sign_in_with_token(user.api_token)
        perform_request
      end

      it { is_expected.to be_success }
      it { expect(JSON.parse(subject.body)).to include({'data' => {'benefits' => ['benefit', 'other benefit']}}) }
    end
  end
end
