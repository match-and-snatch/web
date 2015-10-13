require 'spec_helper'

describe Dashboard::Admin::StaffsController, type: :controller do
  before { sign_in create_admin }

  describe 'GET #index' do
    subject { get 'index' }
    it { should be_success }
  end
end