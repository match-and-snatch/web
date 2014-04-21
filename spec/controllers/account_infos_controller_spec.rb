require 'spec_helper'

describe AccountInfosController do
  describe 'GET #settings' do
    subject { get 'settings' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'PUT #update_general_information' do
    subject { put 'update_general_information' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'PUT #change_password' do
    subject { put 'change_password' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'GET #billing_information' do
    subject { get 'billing_information' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'GET #edit_payment_information' do
    subject { get 'edit_payment_information' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'PUT #update_bank_account_data' do
    subject { put 'update_bank_account_data' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'GET #edit_cc_data' do
    subject { get 'edit_cc_data' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'PUT #update_cc_data' do
    subject { put 'update_cc_data' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'PUT #create_profile_page' do
    subject { put 'create_profile_page' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end

  describe 'PUT #delete_profile_page' do
    subject { put 'delete_profile_page' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      its(:status) { should == 200 }
    end
  end
end