require 'spec_helper'

describe UserManager do
  subject(:manager) { described_class.new(user) }

  describe '#activate' do
    let(:user) { create(:user, activated: false) }

    it 'activates user' do
      expect { manager.activate }.to change { user.activated? }.to(true)
    end

    context 'already activated' do
      before { manager.activate }

      it 'does nothing' do
        expect { manager.activate }.not_to change { user.activated? }.from(true)
      end
    end
  end

  describe '#lock', freeze: true do
    let(:user) { create(:user) }
    let(:lock) { manager.lock(type: :billing) }

    it { expect { lock }.to change { user.last_time_locked_at }.to(Time.zone.now) }
    it { expect { lock }.to change { user.locked? }.to(true) }
    it { expect { lock }.to create_event('account_locked').with_user(user).including_data(type: 'billing', reason: 'manually_set') }

    it { expect { manager.lock(type: :account) }.to create_event('account_locked').with_user(user).including_data(type: 'account', reason: 'manually_set') }
    it { expect { manager.lock(type: 'account') }.to create_event('account_locked').with_user(user).including_data(type: 'account', reason: 'manually_set') }

    it { expect { manager.lock(type: :account, reason: :contribution_limit) }.to create_event('account_locked').with_user(user).including_data(type: 'account', reason: 'contribution_limit') }
    it { expect { manager.lock(type: :account, reason: 'contribution_limit') }.to create_event('account_locked').with_user(user).including_data(type: 'account', reason: 'contribution_limit') }

    context 'invalid type provided' do
      let(:lock) { manager.lock(type: 'invlid type') }

      it { expect { lock rescue nil }.not_to create_event('account_locked') }
      it { expect { lock rescue nil }.not_to change { user.last_time_locked_at } }
      it { expect { lock rescue nil }.not_to change { user.locked? } }
    end

    context 'invalid reason provided' do
      let(:lock) { manager.lock(reason: 'invlid reason') }

      it { expect { lock rescue nil }.not_to create_event('account_locked') }
      it { expect { lock rescue nil }.not_to change { user.last_time_locked_at } }
      it { expect { lock rescue nil }.not_to change { user.locked? } }
    end

    context 'user is admin' do
      let(:user) { create(:user, :admin) }

      it { expect { lock }.not_to change { user.last_time_locked_at } }
      it { expect { lock }.not_to change { user.locked? }.from(false) }
      it { expect { lock }.not_to create_event('account_locked') }
    end
  end

  describe '#unlock', freeze: true do
    let(:user) { create(:user) }
    let(:unlock) { manager.unlock }

    context 'locked' do
      before { manager.lock(type: 'account') }

      it { expect { unlock }.to change { user.locked? }.to(false) }
      it { expect { unlock }.not_to change { user.last_time_locked_at } }
      it { expect { unlock }.to create_event('account_unlocked').with_user(user) }

      context 'user has recent subscriptions' do
        before { manager.log_recent_subscriptions_count(1) }

        it { expect { unlock }.to change { user.recent_subscriptions_count }.from(1).to(0) }
      end
    end

    context 'not locked' do
      it { expect { unlock }.to raise_error(ArgumentError) }
      it { expect { unlock rescue nil }.not_to change { user.last_time_locked_at } }
      it { expect { unlock rescue nil }.not_to change { user.locked? } }
    end
  end

  describe '#make_admin' do
    context 'non admin' do
      let(:user) { create(:user) }

      specify do
        expect { manager.make_admin }.to change { user.is_admin }.from(false).to(true)
      end
    end

    context 'admin' do
      let(:user) { create(:user, :admin) }

      specify do
        expect { manager.make_admin }.to raise_error ManagerError
      end
    end
  end

  describe '#drop_admin' do
    context 'non admin' do
      let(:user) { create(:user) }

      specify do
        expect { manager.drop_admin }.to raise_error ManagerError
      end
    end

    context 'admin' do
      let(:user) { create(:user, :admin) }

      specify do
        expect { manager.drop_admin }.to change { user.is_admin }.from(true).to(false)
      end
    end
  end

  describe '#make_sales' do
    context 'non sales' do
      let(:user) { create(:user) }

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
      let(:user) { create(:user) }

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
    let(:user) { create(:user) }
    let(:another_user) { create(:user, :profile_owner, email: 'another@user.com') }
    let!(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(another_user) }

    describe '#save_last_visited_profile' do
      specify do
        expect { manager.save_last_visited_profile(another_user) }.to change { user.last_visited_profile_id }.from(nil).to(another_user.id)
      end

      context 'unsubscribed' do
        before do
          SubscriptionManager.new(subscriber: user, subscription: subscription).unsubscribe
          subscription.reload
          user
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
    let(:user) { create(:user) }

    it { expect { manager.log_recent_subscriptions_count(1) }.to change { user.recent_subscriptions_count }.from(0).to(1) }
    it { expect { manager.log_recent_subscriptions_count(1) }.to change { user.recent_subscription_at }.from(nil).to(Time.zone.now) }
  end

  describe '#update_adult_subscriptions_limit' do
    let(:user) { create(:user) }

    it { expect { manager.update_adult_subscriptions_limit(10) }.to change { user.reload.adult_subscriptions_limit }.from(6).to(10) }
    it { expect { manager.update_adult_subscriptions_limit(0) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(adult_subscriptions_limit: t_error(:zero)) } }
    it { expect { manager.update_adult_subscriptions_limit('') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(adult_subscriptions_limit: t_error(:empty)) } }
    it { expect { manager.update_adult_subscriptions_limit(nil) }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(adult_subscriptions_limit: t_error(:empty)) } }

    it { expect { manager.update_adult_subscriptions_limit(10) }.to create_event(:subscriptions_limit_changed).including_data(from: 6, to: 10) }

    it 'saves update time', freeze: true do
      expect { manager.update_adult_subscriptions_limit(10) }.to change { user.reload.adult_subscriptions_limit_changed_at }.from(nil).to(Time.zone.now)
    end
  end

  describe '#mark_tos_accepted' do
    let(:user) { create(:user, tos_accepted: false) }

    it { expect { manager.mark_tos_accepted }.to change { user.reload.tos_accepted? }.from(false).to(true) }
    it { expect { manager.mark_tos_accepted }.to create_event(:tos_accepted) }
  end

  describe '#toggle_tos_acceptance' do
    context 'tos accepted' do
      let(:user) { create(:user, tos_accepted: true) }

      it { expect { manager.toggle_tos_acceptance }.to change { user.reload.tos_accepted? }.from(true).to(false) }
    end

    context 'tos not accepted' do
      let(:user) { create(:user, tos_accepted: false) }

      it { expect { manager.toggle_tos_acceptance }.to change { user.reload.tos_accepted? }.from(false).to(true) }
    end
  end

  describe '.reset_tos_acceptance' do
    let(:user) { create(:user, tos_accepted: true) }

    it { expect { described_class.reset_tos_acceptance }.to change { user.reload.tos_accepted? }.from(true).to(false) }
  end
end
