require 'spec_helper'

describe Api::BenefitsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create_user api_token: 'test_token' }
    let(:benefits_params) {  {"0"=>"benefit", "1"=>"other benefit", "2"=>""} }

    subject(:perform_request) { post 'create', user_id: user.id, benefits: benefits_params }

    context 'not authorized' do
      its(:status) { should eq(401) }
    end

    context 'authorized' do
      before do
        request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Token.encode_credentials(user.api_token)
        perform_request
      end

      it { should be_success }
      it { expect(JSON.parse(subject.body)).to include({'data' => ['benefit', 'other benefit']}) }
    end
  end
end
