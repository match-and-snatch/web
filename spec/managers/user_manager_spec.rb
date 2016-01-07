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
    let(:lock) { manager.lock(type: :billing) }

    it { expect { lock }.to change { user.reload.last_time_locked_at }.to(Time.zone.now) }
    it { expect { lock }.to change { user.reload.locked? }.to(true) }
    it { expect { lock }.to create_event('account_locked').with_user(user).including_data(type: 'billing', reason: 'manually_set') }

    it { expect { manager.lock(type: :account) }.to create_event('account_locked').with_user(user).including_data(type: 'account', reason: 'manually_set') }
    it { expect { manager.lock(type: 'account') }.to create_event('account_locked').with_user(user).including_data(type: 'account', reason: 'manually_set') }

    it { expect { manager.lock(type: :account, reason: :contribution_limit) }.to create_event('account_locked').with_user(user).including_data(type: 'account', reason: 'contribution_limit') }
    it { expect { manager.lock(type: :account, reason: 'contribution_limit') }.to create_event('account_locked').with_user(user).including_data(type: 'account', reason: 'contribution_limit') }

    context 'invalid type provided' do
      let(:lock) { manager.lock(type: 'invlid type') }

      it { expect { lock rescue nil }.not_to create_event('account_locked') }
      it { expect { lock rescue nil }.not_to change { user.reload.last_time_locked_at } }
      it { expect { lock rescue nil }.not_to change { user.reload.locked? } }
    end

    context 'invalid reason provided' do
      let(:lock) { manager.lock(reason: 'invlid reason') }

      it { expect { lock rescue nil }.not_to create_event('account_locked') }
      it { expect { lock rescue nil }.not_to change { user.reload.last_time_locked_at } }
      it { expect { lock rescue nil }.not_to change { user.reload.locked? } }
    end
  end

  describe '#unlock', freeze: true do
    let(:user) { create_user }
    let(:unlock) { manager.unlock }

    context 'locked' do
      before { manager.lock(type: 'account') }

      it { expect { unlock }.to change { user.reload.locked? }.to(false) }
      it { expect { unlock }.not_to change { user.reload.last_time_locked_at } }
      it { expect { unlock }.to create_event('account_unlocked').with_user(user) }

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

  describe '#make_sales' do
    context 'non sales' do
      let(:user) { create_user }

      specify do
        expect { manager.make_sales }.to change { user.is_sales }.from(false).to(true)
      end
    end

    context 'sales' do
      let(:user) { create_sales }

      specify do
        expect { manager.make_sales }.to raise_error ManagerError
      end
    end
  end

  describe '#drop_sales' do
    context 'non sales' do
      let(:user) { create_user }

      specify do
        expect { manager.drop_sales }.to raise_error ManagerError
      end
    end

    context 'sales' do
      let(:user) { create_sales }

      specify do
        expect { manager.drop_sales }.to change { user.is_sales }.from(true).to(false)
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
