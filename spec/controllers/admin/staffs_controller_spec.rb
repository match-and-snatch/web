require 'spec_helper'

describe Admin::StaffsController, type: :controller do
  before { sign_in create_admin }

  describe 'GET #index' do
    subject { get 'index' }
    its(:status) { should == 200 }
  end
end