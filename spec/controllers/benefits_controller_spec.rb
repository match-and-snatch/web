require 'spec_helper'

describe BenefitsController do
  describe 'POST #create' do
    let(:user) { create_user }

    subject(:perform_request) { post 'create', user_id: user.id }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in user }
      before { perform_request }

      its(:status) { should == 200 }

      specify do
        expect(assigns(:user)).to eq(user)
      end
    end
  end
end
