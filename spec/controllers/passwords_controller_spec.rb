require 'spec_helper'

describe PasswordsController do
  describe 'PUT #update' do
    let!(:user) { create_user(email: 'test@email.com') }

    before do
      AuthenticationManager.new(email: 'test@email.com').restore_password
      user.reload
    end

    subject { put 'update', password: 'new_one', password_confirmation: 'new_one', token: user.password_reset_token }

    it { should be_success }
    it { expect { subject }.to change { user.reload.password_hash } }
    it { expect { subject }.to change { assigns('notice') } }

    context 'invalid token' do
      subject { put 'update', password: 'new_one', password_confirmation: 'new_one', token: 'invalid' }
      its(:status) { should == 302 }

      context 'empty token' do
        subject { put 'update', password: 'new_one', password_confirmation: 'new_one' }
        its(:status) { should == 302 }
      end
    end
  end
end