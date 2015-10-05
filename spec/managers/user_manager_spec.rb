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

  describe '#lock', freeze: true do
    let(:user) { create_user }
    let(:lock) { manager.lock }

    it { expect { lock }.to change { user.reload.last_time_locked_at }.to(Time.zone.now) }
    it { expect { lock }.to change { user.reload.locked? }.to(true) }
  end

  describe '#unlock', freeze: true do
    let(:user) { create_user }
    let(:unlock) { manager.unlock }

    context 'locked' do
      before { manager.lock }

      it { expect { unlock }.to change { user.reload.locked? }.to(false) }
      it { expect { unlock }.not_to change { user.reload.last_time_locked_at } }

      context 'user has recent subscriptions' do
        before { manager.log_recent_subscriptions_count(1) }

        it { expect { unlock }.to change { user.reload.recent_subscriptions_count }.from(1).to(0) }
      end
    end

    context 'not locked' do
      it { expect { unlock }.to raise_error(ArgumentError) }
      it { expect { unlock rescue nil }.not_to change { user.reload.last_time_locked_at } }
      it { expect { unlock rescue nil }.not_to change { user.reload.locked? } }
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

  describe '#save_last_visited_profile' do
    let(:user) { create_user }
    let(:another_user) { create_profile email: 'another@user.com' }
    let!(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(another_user) }

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

  describe '#log_recent_subscriptions_count', freeze: true do
    let(:user) { create_user }

    it { expect { manager.log_recent_subscriptions_count(1) }.to change { user.recent_subscriptions_count }.from(0).to(1) }
    it { expect { manager.log_recent_subscriptions_count(1) }.to change { user.recent_subscription_at }.from(nil).to(Time.zone.now) }
  end
end
