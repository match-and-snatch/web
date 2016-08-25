require 'spec_helper'

describe OverviewPresenter do
  let(:user) { create(:user) }
  let(:target_user) { create(:user, :profile_owner, email: 'target@user.com') }
  let(:another_target_user) { create(:user, :profile_owner, email: 'another_target@user.com') }
  let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user) }
  let(:another_subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(another_target_user) }
  let(:restore) { SubscriptionManager.new(subscription: subscription).restore }
  let(:unsubscribe) { SubscriptionManager.new(subscription: subscription).unsubscribe }

  before { StripeMock.start }
  after { StripeMock.stop }

  def subscribe
    subscription
  end

  before do
    UserProfileManager.new(user).update_cc_data(number: '4242_4242_4242_4242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
    SubscriptionManager.new(subscription: another_subscription).delete
    subscribe
  end

  context 'subscribers count and revenue' do
    describe '#current_subscribers_count' do
      specify { expect(subject.current_subscribers_count).to eq(1) }

      context 'canceled subscription' do
        specify { expect{ unsubscribe }.to change { subject.current_subscribers_count }.from(1).to(0) }
      end
    end

    describe '#total_subscribers_count' do
      specify { expect(subject.total_subscribers_count).to eq(1) }

      context 'canceled subscription' do
        specify { expect{ unsubscribe }.not_to change { subject.total_subscribers_count } }
      end
    end

    describe '#daily_subscribers_count' do
      specify { expect(subject.daily_subscribers_count).to eq(1) }

      context 'canceled subscription' do
        specify { expect{ unsubscribe }.to change { subject.daily_subscribers_count }.from(1).to(0) }
      end
    end

    describe '#daily_total_subscribers_count' do
      specify { expect(subject.daily_total_subscribers_count).to eq(1) }

      context 'canceled subscription' do
        specify { expect{ unsubscribe }.not_to change { subject.daily_total_subscribers_count } }
      end
    end

    describe '#daily_new_subscriptions_revenue' do
      specify { expect(subject.daily_new_subscriptions_revenue).to eq(499) }

      context 'next day' do
        specify do
          Timecop.freeze(1.days.from_now) do
            expect(subject.daily_new_subscriptions_revenue).to eq(0)
          end
        end
      end
    end

    describe '#daily_recurring_subscriptions_revenue' do
      specify { expect(subject.daily_recurring_subscriptions_revenue).to eq(0) }
      let(:user) { create :user, :with_cc }

      context 'recurring payment is performed' do
        def subscribe
          Timecop.travel(32.days.ago) do
            SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create(:user, :profile_owner, email: 'another_target@user.com'))
          end
        end

        specify do
          Timecop.freeze(1.days.from_now) do
            expect { Billing::ChargeJob.new.perform }.to change { subject.daily_recurring_subscriptions_revenue }.from(0).to(499)
          end
        end
      end
    end
  end

  context 'unsubscribers count' do
    before { unsubscribe }

    describe '#current_unsubscribers_count' do
      specify { expect(subject.current_unsubscribers_count).to eq(1) }

      context 'restored subscription' do
        specify { expect{ restore }.to change { subject.current_unsubscribers_count }.from(1).to(0) }
      end

      context 'rejected subscription' do
        before do
          manager = SubscriptionManager.new(subscription: subscription)
          manager.restore
          manager.reject
        end

        specify { expect(subject.current_unsubscribers_count).to eq(1) }
      end
    end

    describe '#daily_unsubscribers_count' do
      specify { expect(subject.daily_unsubscribers_count).to eq(1) }

      context 'restored subscription' do
        specify { expect{ restore }.to change { subject.daily_unsubscribers_count }.from(1).to(0) }
      end
    end

    describe '#daily_total_unsubscribers_count' do
      specify { expect(subject.daily_total_unsubscribers_count).to eq(1) }

      context 'restored subscription' do
        specify { expect{ restore }.not_to change { subject.daily_total_unsubscribers_count } }
      end
    end
  end

  context 'failed payments count' do
    def subscribe
      StripeMock.prepare_card_error(:card_declined)
      UserProfileManager.new(user).update_cc_data(number: '4000_0000_0000_0341', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA') rescue nil
      SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create(:user, :profile_owner, email: 'another_target@user.com')) rescue nil
    end

    describe '#current_failed_payments_count' do
      specify { expect(subject.current_failed_payments_count).to eq(1) }

      context 'restored subscription' do
        let(:restore) { UserProfileManager.new(user).update_cc_data(number: '4242_4242_4242_4242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA') }

        specify { expect { restore }.to change { subject.current_failed_payments_count }.from(1).to(0) }
      end
    end

    describe '#daily_failed_payments_count' do
      specify { expect(subject.daily_failed_payments_count).to eq(1) }
    end
  end

  describe '#total_gross_sales' do
    specify { expect(subject.total_gross_sales).to eq(998) }
  end

  describe '#total_connectpal_fees' do
    specify { expect(subject.total_connectpal_fees).to eq(120.036) }
  end

  describe '#total_stripe_fees' do
    specify { expect(subject.total_stripe_fees).to eq(77.964) }
  end

  describe '#daily_gross_sales' do
    specify { expect(subject.daily_gross_sales).to eq(998) }
  end

  context 'tos fees' do
    describe '#daily_tos_fees' do
      specify { expect { unsubscribe }.to change { subject.daily_tos_fees }.from(0).to(400) }

      context 'restored subscription' do
        before { unsubscribe }
        specify { expect{ restore }.to change { subject.daily_tos_fees }.from(400).to(0) }
      end
    end

    describe '#total_tos_fees' do
      specify { expect { unsubscribe }.to change { subject.total_tos_fees }.from(0).to(400) }

      context 'restored subscription' do
        before { unsubscribe }
        specify { expect{ restore }.to change { subject.total_tos_fees }.from(400).to(0) }
      end
    end
  end

  describe '#daily_stripe_fees' do
    specify { expect(subject.daily_stripe_fees).to eq(77.964) }
  end

  describe '#daily_contributions_revenue' do
    specify { expect(subject.daily_contributions_revenue).to eq(0) }

    context 'with contribution' do
      let(:contribute) { ContributionManager.new(user: user).create(amount: 10, target_user: target_user) }

      before do
        4.times do |i|
          SubscriptionManager.new(subscriber: create(:user)).subscribe_to(target_user)
        end
      end

      specify { expect { contribute }.to change { subject.daily_contributions_revenue }.from(0).to(10) }
    end
  end
end
