require 'spec_helper'

describe Owner::FirstStepsController, type: :controller do
  describe 'GET #show' do
    subject(:perform_request) { get 'show' }

    context 'authorized' do
      let(:user) { create_user }
      before { sign_in user }
      it { should be_success }

      context 'already have profile created' do
        pending 'redirects me to my profile page'
      end
    end

    context 'unauthorized' do
      its(:status) { should == 401 }
    end
  end
end