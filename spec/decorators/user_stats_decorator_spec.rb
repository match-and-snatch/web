require 'spec_helper'

describe UserStatsDecorator do
  let(:user) { User.new }
  subject { described_class.new(user) }

  context 'removed subscriptions' do
    before { StripeMock.start }
    after { StripeMock.stop }

    let(:user) { create_profile }
    let(:subscriber) { create_user(email: 'subscriber@user.com') }
    let(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_and_pay_for(user) }

    before do
      UserProfileManager.new(subscriber).update_cc_data(number: '4242424242424242', cvc: '333', expiry_month: '12', expiry_year: 2018, address_line_1: 'test', zip: '12345', city: 'LA', state: 'CA')
      SubscriptionManager.new(subscription: subscription).unsubscribe
    end

    describe '#unsubscribed_ever_count' do
      it 'returns count of removed subscriptions' do
        expect(subject.unsubscribed_ever_count).to eq(1)
      end
    end

    describe '#connectpal_and_tos' do
      it 'returns right cost' do
        expect(subject.connectpal_and_tos).to eq(699)
      end
    end
  end

  describe '#uploaded_bytes' do
    let(:user) { create(:user) }
    let!(:photo) { create(:photo, user: user) }

    it { expect(subject.uploaded_bytes).to eq(100) }

    context 'with removed upload' do
      let!(:photo) { create(:photo, user: user, removed: true) }

      it { expect(subject.uploaded_bytes).to eq(0) }
    end
  end
end
