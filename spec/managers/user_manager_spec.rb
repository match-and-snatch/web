require 'spec_helper'

describe UserManager do
  subject(:manager) { described_class.new(user) }

  describe '#activate' do
    let(:user) { create_user }

    it 'activates user' do
      expect { manager.activate }.to change { user.reload.activated? }.to(true)
    end

    context 'already activated' do
      before { manager.activate }

      it 'does nothing' do
        expect { manager.activate }.not_to change { user.reload.activated? }.from(true)
      end
    end
  end

  describe '#make_admin' do
    context 'non admin' do
      let(:user) { create_user }

      specify do
        expect { manager.make_admin }.to change { user.is_admin }.from(false).to(true)
      end
    end

    context 'admin' do
      let(:user) { create_admin }

      specify do
        expect { manager.make_admin }.to raise_error ManagerError
      end
    end
  end

  describe '#drop_admin' do
    context 'non admin' do
      let(:user) { create_user }

      specify do
        expect { manager.drop_admin }.to raise_error ManagerError
      end
    end

    context 'admin' do
      let(:user) { create_admin }

      specify do
        expect { manager.drop_admin }.to change { user.is_admin }.from(true).to(false)
      end
    end
  end
end
