require 'spec_helper'

describe OverviewPresenter do
  let(:user) { create_user }
  let(:target_user) { create_profile(email: 'target@user.com') }
  let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user) }

  subject { described_class.new }

  before { StripeMock.start }
  after { StripeMock.stop }

  before do
    UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018)
    subscription
  end

  describe '#total_subscribers_count' do
    specify do
      expect(subject.total_subscribers_count).to eq(1)
    end
  end

  describe '#total_active_subscribers_count' do
    specify do
      expect(subject.total_active_subscribers_count).to eq(1)
    end
  end

  describe '#total_unsubscribers_count' do
    before do
      SubscriptionManager.new(subscription: subscription).unsubscribe
    end

    specify do
      expect(subject.total_unsubscribers_count).to eq(1)
    end
  end

  context 'failed payment' do
    before do
      StripeMock.prepare_card_error(:card_declined)
      UserProfileManager.new(user).update_cc_data(number: '4000_0000_0000_0341', cvc: '333', expiry_month: '12', expiry_year: 2018)
      SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(create_profile(email: 'another_target@user.com'))
    end

    describe '#total_failed_payments_count' do
      specify do
        expect(subject.total_failed_payments_count).to eq(1)
      end
    end
  
    describe '#daily_failed_payments_count' do
      specify do
        expect(subject.daily_failed_payments_count).to eq(1)
      end
    end
  end

  describe '#total_gross_sales' do
    specify do
      expect(subject.total_gross_sales).to eq(500)
    end
  end

  describe '#total_connectpal_fees' do
    specify do
      expect(subject.total_connectpal_fees).to eq(54.5)
    end
  end

  describe '#stripe_fees' do
    specify do
      expect(subject.stripe_fees).to eq(44.5)
    end
  end

  describe '#daily_payments' do
    specify do
      expect(subject.daily_payments).to eq([Payment.first])
    end
  end

  describe '#daily_gross_sales' do
    specify do
      expect(subject.daily_gross_sales).to eq(500)
    end
  end

  describe '#daily_subscribers_count' do
    specify do
      expect(subject.daily_subscribers_count).to eq(1)
    end
  end

  context 'canceled subscriptions' do
    before do
      SubscriptionManager.new(subscription: subscription).unsubscribe
    end

    describe '#daily_unsubscribers' do
      specify do
        expect(subject.daily_unsubscribers).to eq([subscription])
      end
    end

    describe '#daily_unsubscribers_count' do
      specify do
        expect(subject.daily_unsubscribers_count).to eq(1)
      end
    end

    describe '#daily_tos_fees' do
      specify do
        expect(subject.daily_tos_fees).to eq(500)
      end
    end

    describe '#total_tos_fees' do
      specify do
        expect(subject.total_tos_fees).to eq(500)
      end
    end
  end

  describe '#daily_stripe_fees' do
    specify do
      expect(subject.daily_stripe_fees).to eq(44.5)
    end
  end
end