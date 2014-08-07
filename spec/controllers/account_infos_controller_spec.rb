require 'spec_helper'

describe AccountInfosController, type: :controller do
  describe 'GET #show' do
    let(:user) { create_user }
    subject(:perform_request) { get 'show' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before do
        sign_in user
        perform_request
      end

      it { expect(assigns('user')).to eq user }
      it { should be_success }
    end
  end

  describe 'GET #details' do
    subject(:perform_request) { get 'details' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before do
        sign_in
        perform_request
      end

      it { expect(assigns(:user)).to be_a_kind_of(UserStatsDecorator) }
      it { should be_success }
    end
  end

  describe 'GET #settings' do
    subject { get 'settings' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #update_account_picture' do
    subject { put 'update_account_picture', profile_picture_data_params }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
      its(:body) { should match_regex /replace/ }
    end
  end

  describe 'PUT #update_general_information' do
    subject { put 'update_general_information' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #update_slug' do
    subject { put 'update_slug', slug: 'anotherSlug' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
      its(:body) { should match_regex /notice/ }
      its(:body) { should match_regex /reload/ }
    end
  end

  describe 'PUT #change_password' do
    subject { put 'change_password' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'GET #billing_information' do
    subject { get 'billing_information' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'GET #edit_payment_information' do
    subject { get 'edit_payment_information' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #update_bank_account_data' do
    subject { put 'update_bank_account_data' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'GET #edit_cc_data' do
    subject { get 'edit_cc_data' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #update_cc_data' do
    subject { put 'update_cc_data' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #create_profile_page' do
    subject { put 'create_profile_page' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #confirm_profile_page_removal' do
    subject { get 'confirm_profile_page_removal' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #delete_profile_page' do
    subject { put 'delete_profile_page' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #enable_vacation_mode' do
    subject { put 'enable_vacation_mode', vacation_message: 'test' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #disable_vacation_mode' do
    subject { put 'disable_vacation_mode' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #enable_rss' do
    subject { put 'enable_rss' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #disable_rss' do
    subject { put 'disable_rss' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #enable_downloads' do
    subject { put 'enable_downloads' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #disable_downloads' do
    subject { put 'disable_downloads' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #enable_itunes' do
    subject { put 'enable_itunes' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end

  describe 'PUT #disable_itunes' do
    subject { put 'disable_itunes' }

    context 'not authorized' do
      its(:status) { should == 401 }
    end

    context 'authorized' do
      before { sign_in }
      it { should be_success }
    end
  end
end
