require 'spec_helper'

describe OverviewPresenter do
  subject { described_class.new }

  let(:user) { create_user }
  let(:target_user) { create_profile(email: 'target@user.com') }
  let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user) }
  let(:restore) { SubscriptionManager.new(subscription: subscription).restore }
  let(:unsubscribe) { SubscriptionManager.new(subscription: subscription).unsubscribe }


  before { StripeMock.start }
  after { StripeMock.stop }

  before do
    UserProfileManager.new(user).update_cc_data(number: '4242_4242_4242_4242', cvc: '333', expiry_month: '12', expiry_year: 2018)
    subscription
  end

  context 'subscribers count' do
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
  end

  context 'unsubscribers count' do
    before { unsubscribe }

    describe '#current_unsubscribers_count' do
      specify { expect(subject.current_unsubscribers_count).to eq(1) }

      context 'restored subscription' do
        specify { expect{ restore }.to change { subject.current_unsubscribers_count }.from(1).to(0) }
      end
    end

    describe '#total_unsubscribers_count' do
      specify { expect(subject.total_unsubscribers_count).to eq(1) }

      context 'restored subscription' do
        specify { expect{ restore }.not_to change { subject.total_unsubscribers_count } }
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
    before do
      StripeMock.prepare_card_error(:card_declined)
      UserProfileManager.new(user).update_cc_data(number: '4000_0000_0000_0341', cvc: '333', expiry_month: '12', expiry_year: 2018)
      SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create_profile(email: 'another_target@user.com'))
    end

    describe '#current_failed_payments_count' do
      specify { expect(subject.current_failed_payments_count).to eq(1) }

      context 'restored subscription' do
        let(:restore) { UserProfileManager.new(user).update_cc_data(number: '4242_4242_4242_4242', cvc: '333', expiry_month: '12', expiry_year: 2018) }

        specify { expect { restore }.to change { subject.current_failed_payments_count }.from(1).to(0) }
      end
    end

    describe '#total_failed_payments_count' do
      specify { expect(subject.total_failed_payments_count).to eq(1) }
    end
  
    describe '#daily_failed_payments_count' do
      specify { expect(subject.daily_failed_payments_count).to eq(1) }
    end
  end

  describe '#total_gross_sales' do
    specify { expect(subject.total_gross_sales).to eq(599) }
  end

  describe '#total_connectpal_fees' do
    specify { expect(subject.total_connectpal_fees).to eq(51.629) }
  end

  describe '#total_stripe_fees' do
    specify { expect(subject.total_stripe_fees).to eq(47.371) }
  end

  describe '#daily_gross_sales' do
    specify { expect(subject.daily_gross_sales).to eq(599) }
  end

  context 'tos fees' do
    describe '#daily_tos_fees' do
      specify { expect { unsubscribe }.to change { subject.daily_tos_fees }.from(0).to(500) }

      context 'restored subscription' do
        before { unsubscribe }
        specify { expect{ restore }.to change { subject.daily_tos_fees }.from(500).to(0) }
      end
    end

    describe '#total_tos_fees' do
      specify { expect { unsubscribe }.to change { subject.total_tos_fees }.from(0).to(500) }

      context 'restored subscription' do
        before { unsubscribe }
        specify { expect{ restore }.to change { subject.total_tos_fees }.from(500).to(0) }
      end
    end
  end

  describe '#daily_stripe_fees' do
    specify { expect(subject.daily_stripe_fees).to eq(47.371) }
  end
end
