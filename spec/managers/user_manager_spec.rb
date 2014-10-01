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

  context 'last visited profile' do
    let(:user) { create_user }
    let(:another_user) { create_profile email: 'another@user.com' }
    let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(another_user) }

    before { subscription }

    describe '#save_last_visited_profile' do
      specify do
        expect { manager.save_last_visited_profile(another_user) }.to change { user.last_visited_profile_id }.from(nil).to(another_user.id)
      end

      context 'unsubscribed' do
        before do
          SubscriptionManager.new(subscriber: user, subscription: subscription).unsubscribe
          subscription.reload
          user.reload
        end

        specify do
          Timecop.freeze(38.days.from_now) do
            expect { manager.save_last_visited_profile(another_user) }.not_to change { user.last_visited_profile_id }.from(nil)
          end
        end
      end
    end
  end
end
