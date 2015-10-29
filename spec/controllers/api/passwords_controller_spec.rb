require 'spec_helper'

describe Api::PasswordsController, type: :controller do
  let!(:user) { create_user email: 'test@email.com', api_token: 'token' }
  let(:token) { user.password_reset_token }

  describe 'PUT #update' do

    before do
      AuthenticationManager.new(email: 'test@email.com').restore_password
      user.reload
    end

    subject { put 'update', password: 'new_one', password_confirmation: 'new_one', token: token, format: :json }

    it { should be_success }
    it { expect { subject }.to change { user.reload.password_hash } }
    it { expect { subject }.to change { assigns('notice') } }

    context 'invalid token' do
      let(:token) { 'invalid' }

      it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
      it { expect { subject }.to change { assigns('notice') } }

      context 'empty token' do
        subject { put 'update', password: 'new_one', password_confirmation: 'new_one', format: :json }

        it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
      end
    end
  end

  describe 'POST #restore' do
    subject { post 'restore', email: 'test@email.com', format: :json }

    it { should be_success }
    it { expect { subject }.to change { assigns('notice') } }

    context 'wrong email' do
      subject { post 'restore', email: 'wrong@email.com', format: :json }

      it { should be_success }
    end
  end

  describe 'GET #edit' do
    before do
      AuthenticationManager.new(email: 'test@email.com').restore_password
      user.reload
    end

    subject { get 'edit', token: token, format: :json }

    it { should be_success }

    context 'invalid token' do
      let(:token) { 'invalid' }

      it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
      it { expect { subject }.to change { assigns('notice') } }

      context 'empty token' do
        subject { put 'update', password: 'new_one', password_confirmation: 'new_one', format: :json }

        it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
      end
    end
  end
end
