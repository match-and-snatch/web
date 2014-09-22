require 'spec_helper'

describe UserStatsDecorator do
  let(:user) { User.new }
  subject { described_class.new(user) }

  before { StripeMock.start }
  after { StripeMock.stop }

  context 'removed subscriptions' do
    let(:user) { create_profile }
    let(:subscriber) { create_user(email: 'subscriber@user.com') }
    let(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_and_pay_for(user) }

    before do
      UserProfileManager.new(subscriber).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018)
      SubscriptionManager.new(subscription: subscription).unsubscribe
    end

    describe '#unsubscribed_ever' do
      it 'returns removed subscription' do
        expect(subject.unsubscribed_ever).to eq([subscription])
      end
    end

    describe '#unsubscribed_ever_count' do
      it 'returns count of removed subscriptions' do
        expect(subject.unsubscribed_ever_count).to eq(1)
      end
    end

    describe '#connectpal_and_tos' do
      it 'returns right cost' do
        expect(subject.connectpal_and_tos).to eq(599)
      end
    end
  end

end