require 'spec_helper'

describe Admin::ProfileOwnersController, type: :controller do
  before { sign_in create_admin(email: 'admin@gmail.com') }
  let(:user) { create_user }

  describe '#enable_billing' do
    subject { put :enable_billing, id: user.id }
    it { should be_success }
  end

  describe '#disable_billing' do
    subject { put :disable_billing, id: user.id }
    it { should be_success }
  end
end
