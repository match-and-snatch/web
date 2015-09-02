require 'spec_helper'

describe AuthenticationManager do
  let(:email) { 'szinin@gmail.com' }
  let(:password) { 'qwerty' }
  let(:password_confirmation) { 'qwerty' }
  let(:first_name) { 'sergei' }
  let(:last_name) { 'zinin' }
  let(:api_token) { 'invalid' }

  subject(:manager) { described_class.new(email: email,
                                          password: password,
                                          password_confirmation: password_confirmation,
                                          first_name: first_name,
                                          last_name: last_name,
                                          api_token: api_token) }

  describe '#register' do
    subject(:register) { manager.register }

    it { should be_a User }
    it { should be_valid }
    it { should_not be_a_new_record }
    its(:email) { should == email }
    its(:password_hash) { should_not be_blank }
    its(:full_name) { should == 'Sergei Zinin' }
    its(:auth_token) { should_not be_blank }

    specify { expect { register }.to change(User, :count).by(1) }
    specify { expect { register }.to create_event(:registered) }

    context 'already registered user' do
      before { manager.register }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:taken)) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end

    context 'invalid email' do
      context '"whatever"' do
        let(:email) { 'whatever' }
        specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:default)) } }
        specify { expect { register rescue nil }.not_to create_event(:registered) }
      end

      context '"what ever@gmail.com"' do
        let(:email) { 'what ever@gmail.com' }
        specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:default)) } }
        specify { expect { register rescue nil }.not_to create_event(:registered) }
      end
    end

    context 'empty email' do
      let(:email) { '' }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:empty)) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end

    context 'password confirmation does not match' do
      let(:password_confirmation) { 'qwertyui' }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:password_confirmation) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end

    context 'short password' do
      let(:password) { 'qwer' }
      let(:password_confirmation) { 'qwer' }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to have_key(:password) } }
      specify { expect { register }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).not_to have_key(:password_confirmation) } }
      specify { expect { register rescue nil }.not_to create_event(:registered) }
    end
  end

  describe '#authenticate' do
    subject(:authenticate) { manager.authenticate }

    context 'registered user' do
      before { manager.register }

      it { should be_a User }
      it { should_not be_new_record }
      its(:email) { should == email }

      specify { expect { authenticate }.to create_event(:logged_in) }
    end

    context 'not registered user' do
      specify { expect { authenticate }.to raise_error(ManagerError) }
      specify { expect { authenticate rescue nil }.not_to create_event(:logged_in) }
    end

    context 'having wrong password' do
      before do
        manager.register
      end

      specify do
        expect { described_class.new(email: email, password: 'wrong_password').authenticate }.to raise_error(AuthenticationError)
      end

      specify do
        expect { described_class.new(email: email, password: 'wrong_password').authenticate rescue nil }.not_to create_event(:logged_in)
      end
    end
  end

  describe '#authenticate_api' do
    subject(:authenticate) { manager.authenticate_api }

    context 'token is not provided' do
      let(:api_token) { nil }
      specify { expect { authenticate }.to raise_error(AuthenticationError) }
    end

    context 'invalid token provided' do
      let(:api_token) { 'invalid' }
      specify { expect { authenticate }.to raise_error(AuthenticationError) }
    end

    context 'valid token' do
      let(:user) { create_user api_token: 'test' }
      let(:api_token) { user.api_token }

      specify { expect(authenticate).to eq(user) }
    end
  end
end
