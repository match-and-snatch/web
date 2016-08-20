require 'spec_helper'

describe Owner::SecondStepsController, type: :controller do
  let(:user) { create(:user) }

  describe 'GET #show' do
    subject(:perform_request) { get 'show' }

    context 'authorized' do
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

  describe 'PUT #update' do
    subject(:perform_request) { put :update, params: {cost: 10,
                                                      profile_name: 'test',
                                                      holder_name: 'test',
                                                      routing_number: '111111111',
                                                      account_number: '123456'} }
    context 'authorized' do
      before { sign_in user }
      it { should be_success }

      context 'already have profile created' do
        pending 'shows error'
      end
    end

    context 'unauthorized' do
      its(:status) { should == 401 }
    end
  end
end
