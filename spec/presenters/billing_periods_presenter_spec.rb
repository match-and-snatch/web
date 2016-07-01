require 'spec_helper'

describe BillingPeriodsPresenter do
  let(:user) { create(:user) }
  let(:target_user) { create(:user, :profile_owner, email: 'target@user.com', cost: 5_00, subscription_cost: 6_99, subscription_fees: 1_99) }
  let(:another_target_user) { create(:user, :profile_owner, email: 'another_target@user.com', cost: 5_00, subscription_cost: 6_99, subscription_fees: 1_99) }
  let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(target_user) }
  let(:another_subscription) { SubscriptionManager.new(subscriber: user).subscribe_and_pay_for(another_target_user) }

  subject { described_class.new(user: target_user).collection.first }

  before { StripeMock.start }
  after { StripeMock.stop }

  before do
    UserProfileManager.new(user).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
    subscription
    SubscriptionManager.new(subscription: another_subscription).delete
  end

  describe '#total_gross' do
    specify do
      expect(subject.total_gross).to eq(6_99)
    end
  end

  describe '#connectpal_fee' do
    specify do
      expect(subject.connectpal_fee).to eq(1_56.418)
    end
  end

  describe '#stripe_fee' do
    specify do
      expect(subject.stripe_fee).to eq(42.582)
    end
  end

  context 'canceled subscriptions' do
    before do
      SubscriptionManager.new(subscription: subscription).unsubscribe
    end

    describe '#tos_fee' do
      specify do
        expect(subject.tos_fee).to eq(5_00)
      end
    end

    describe '#unsubscribed_count' do
      specify do
        expect(subject.unsubscribed_count).to eq(1)
      end
    end
  end

  # describe '#payout' do
  #   before do
  #     TransferManager.new(recipient: target_user).transfer(amount: '666', descriptor: 'Ha BoTky', month: '12')
  #   end
  #
  #   specify do
  #     expect(subject.payout).to eq(666)
  #   end
  # end
end
