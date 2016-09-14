RSpec.describe PasswordsController, type: :controller do
  describe 'PUT #update' do
    let!(:user) { create(:user, email: 'test@email.com') }

    before do
      AuthenticationManager.new(email: 'test@email.com').restore_password
      user.reload
    end

    subject { put :update, params: {password: 'new_one', password_confirmation: 'new_one', token: user.password_reset_token} }

    it { is_expected.to be_success }
    it { expect { subject }.to change { user.reload.password_hash } }
    it { expect { subject }.to change { assigns('notice') } }

    context 'invalid token' do
      subject { put :update, params: {password: 'new_one', password_confirmation: 'new_one', token: 'invalid'} }
      its(:status) { is_expected.to eq(302) }

      context 'empty token' do
        subject { put :update, params: {password: 'new_one', password_confirmation: 'new_one'} }
        its(:status) { is_expected.to eq(302) }
      end
    end
  end

  pending '#restore'
  pending '#edit'
end
