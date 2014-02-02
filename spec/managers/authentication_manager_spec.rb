require 'spec_helper'

describe AuthenticationManager do
  let(:email) { 'szinin@gmail.com' }
  let(:password) { 'qwerty' }

  subject(:manager) { described_class.new(email, password) }

  describe '#register' do
    subject(:register) { manager.register }

    it { should be_a User }
    it { should be_valid }
    its(:new_record?) { should be_false }
    its(:email) { should == email }
    its(:password_hash) { should_not be_blank }
    its(:password_salt) { should_not be_blank }

    specify { expect { manager.register }.to change(User, :count).by(1) }

    context 'already registered user' do
      before { manager.register }
      specify { expect { manager.register }.to raise_error(ManagerError, /is already taken/) }
    end
  end

  describe '#authenticate' do
    subject(:authenticate) { manager.authenticate }

    context 'registered user' do
      before { manager.register }

      it { should be_a User }
      its(:new_record?) { should be_false }
      its(:email) { should == email }
    end

    context 'not registered user' do
      specify { expect { manager.authenticate }.to raise_error(ManagerError) }
    end

    context 'having wrong password' do
      before { manager.register }

      specify do
        expect { described_class.new(email, 'wrong_password').authenticate }.to raise_error(ManagerError)
      end
    end
  end
end