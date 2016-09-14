RSpec.describe Api::PasswordsController, type: :controller do
  let!(:user) { create(:user, email: 'test@email.com') }
  let(:token) { user.password_reset_token }

  describe 'PUT #update' do

    before do
      AuthenticationManager.new(email: 'test@email.com').restore_password
      user.reload
    end

    subject { put :update, params: {password: 'new_one', password_confirmation: 'new_one', token: token}, format: :json }

    it { is_expected.to be_success }
    it { expect { subject }.to change { user.reload.password_hash } }
    it { expect { subject }.to change { assigns('notice') } }

    context 'invalid token' do
      let(:token) { 'invalid' }

      it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
      it { expect { subject }.to change { assigns('notice') } }

      context 'empty token' do
        subject { put :update, params: {password: 'new_one', password_confirmation: 'new_one'}, format: :json }

        it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
      end
    end
  end

  describe 'POST #restore' do
    subject { post :restore, params: {email: 'test@email.com'}, format: :json }

    it { is_expected.to be_success }
    it { expect { subject }.to change { assigns('notice') } }

    context 'wrong email' do
      subject { post :restore, params: {email: 'wrong@email.com'}, format: :json }

      it { is_expected.to be_success }
    end
  end

  describe 'GET #edit' do
    before do
      AuthenticationManager.new(email: 'test@email.com').restore_password
      user.reload
    end

    subject { get :edit, params: {token: token}, format: :json }

    it { is_expected.to be_success }

    context 'invalid token' do
      let(:token) { 'invalid' }

      it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
      it { expect { subject }.to change { assigns('notice') } }

      context 'empty token' do
        subject { put :update, params: {password: 'new_one', password_confirmation: 'new_one'}, format: :json }

        it { expect(JSON.parse(subject.body)).to include({'status'=>404}) }
      end
    end
  end
end
