require 'spec_helper'

describe BenefitsController, type: :controller do
  describe 'POST #create' do
    let(:user) { create_user }
    let(:benefits_params){  {"0"=>"benefit", "1"=>"other benefit", "2"=>"", "3"=>"", "4"=>"", "5"=>"", "6"=>"", "7"=>"", "8"=>"", "9"=>""} }

    subject(:perform_request) { post 'create', user_id: user.id, benefits: benefits_params }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in user }
      before { perform_request }

      it { should be_success }

      specify do
        expect(assigns(:benefits)).to match_array(user.benefits(true))
      end

      specify do
        expect(assigns(:user)).to eq(user)
      end
    end
  end
end
