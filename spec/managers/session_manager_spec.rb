require 'spec_helper'

describe SessionManager, type: :request do
  subject(:manager) { described_class.new(cookies) }

  let(:email) { 'szinin@gmail.com' }
  let(:password) { 'qwerty' }

  describe '#login' do
    context 'authorized user' do
      let!(:user) { create_user(email: email, password: password, password_confirmation: password) }

      specify do
        expect(user.auth_token).not_to be_blank
      end

      specify do
        expect { manager.login(email, password) }.to change { cookies['auth_token'] }.from(nil).to(user.auth_token)
      end
    end

    context 'unauthorized user' do
      specify do
        expect { manager.login(email, password) }.to raise_error(ManagerError)
      end
    end
  end

  describe '#logout' do
    let!(:user) { create_user(email: email, password: password, password_confirmation: password) }

    before do
      manager.login(email, password)
    end

    specify do
      expect { manager.logout }.to change { cookies['auth_token'] }.from(user.auth_token).to('')
    end
  end

  describe '#current_user' do
    its(:current_user) { should be_a CurrentUserDecorator }
    its(:current_user) { should_not be_authorized }

    context 'authorized user' do
      let!(:user) { create_user(email: email, password: password, password_confirmation: password) }

      before do
        manager.login(email, password)
      end

      its(:current_user) { should be_authorized }
    end
  end
end