require 'spec_helper'

describe SessionManager do
  let(:session) { {} }

  subject(:manager) { described_class.new(session) }

  let(:email) { 'szinin@gmail.com' }
  let(:password) { 'qwerty' }
  let(:login) { 'sergei' }

  describe '#login' do
    context 'authorized user' do
      let!(:user) { AuthenticationManager.new(email, password).register(login) }

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
    let!(:user) { AuthenticationManager.new(email, password).register(login) }

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
      let!(:user) { AuthenticationManager.new(email, password).register(login) }

      before do
        manager.login(email, password)
      end

      its(:current_user) { should be_authorized }
    end
  end
end