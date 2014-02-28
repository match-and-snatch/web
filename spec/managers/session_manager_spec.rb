require 'spec_helper'

describe SessionManager do
  let(:session) { {} }

  subject(:manager) { described_class.new(session) }

  let(:email) { 'szinin@gmail.com' }
  let(:password) { 'qwerty' }

  describe '#login' do
    context 'authorized user' do
      let!(:user) { create_user(email: email, password: password, password_confirmation: password) }

      specify do
        expect { manager.login(email, password) }.to change { session[:user_id] }.from(nil).to(user.id)
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
      expect { manager.logout }.to change { session[:user_id] }.from(user.id).to(nil)
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