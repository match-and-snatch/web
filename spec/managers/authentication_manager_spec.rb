require 'spec_helper'

describe AuthenticationManager do
  let(:email) { 'szinin@gmail.com' }
  let(:password) { 'qwerty' }
  let(:password_confirmation) { 'qwerty' }
  let(:first_name) { 'sergei' }
  let(:last_name) { 'zinin' }

  subject(:manager) { described_class.new(email: email,
                                          password: password,
                                          password_confirmation: password_confirmation,
                                          first_name: first_name,
                                          last_name: last_name) }

  describe '#register' do
    subject(:register) { manager.register }

    it { should be_a User }
    it { should be_valid }
    it { should_not be_a_new_record }
    its(:email) { should == email }
    its(:password_hash) { should_not be_blank }
    its(:password_salt) { should_not be_blank }
    its(:full_name) { should == 'Sergei Zinin' }

    specify { expect { manager.register }.to change(User, :count).by(1) }

    context 'already registered user' do
      before { manager.register }
      specify { expect { manager.register }.to raise_error(ManagerError, /already taken/) }
    end

    context 'empty email' do
      let(:email) { '' }
      specify { expect { manager.register }.to raise_error(ManagerError, /empty/) }
    end

    context 'password confirmation does not match' do
      let(:password_confirmation) { 'qwertyui' }
      specify { expect { manager.register }.to raise_error(ManagerError, /match/) }
    end

    context 'short password' do
      let(:password) { 'qwer' }
      let(:password_confirmation) { 'qwer' }
      specify { expect { manager.register }.to raise_error(ManagerError, /at least 5/) }
    end
  end

  describe '#authenticate' do
    subject(:authenticate) { manager.authenticate }

    context 'registered user' do
      before { manager.register }

      it { should be_a User }
      it { should_not be_new_record }
      its(:email) { should == email }
    end

    context 'not registered user' do
      specify { expect { manager.authenticate }.to raise_error(ManagerError) }
    end

    context 'having wrong password' do
      before { manager.register }

      specify do
        expect { described_class.new(email: email, password: 'wrong_password').authenticate }.to raise_error(ManagerError)
      end
    end
  end
end