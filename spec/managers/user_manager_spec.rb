require 'spec_helper'

describe UserManager do
  subject(:manager) { described_class.new(user) }

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