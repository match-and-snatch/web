require 'spec_helper'

describe UserStatsManager do
  let(:user) { create_user }
  let(:target_user) { create_profile email: 'target@gmail.com' }
  let(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

  subject { described_class.new(target_user) }

  describe '#log_subscriptions_count' do
    before do
      subscription
      target_user.subscription_daily_count_change_events.delete_all
    end

    let(:stats_entry) { subject.log_subscriptions_count }

    it 'creates subscription_daily_count_change_event if it does not existed' do
      expect { subject.log_subscriptions_count }.to change { target_user.subscription_daily_count_change_events.count }.from(0).to(1)
    end

    it 'returns the same stats entry instead of create new in the same day' do
      another_subject = subject.log_subscriptions_count
      expect(subject.log_subscriptions_count).to eq(another_subject)
    end

    it 'returns another stats entry in another day' do
      another_subject = subject.log_subscriptions_count
      Timecop.freeze(1.days.from_now) do
        expect(subject.log_subscriptions_count).not_to eq(another_subject)
      end
    end

    context 'successfull subscription' do
      specify do
        expect(stats_entry.subscriptions_count).to eq(1)
        expect(stats_entry.unsubscribers_count).to eq(0)
        expect(stats_entry.failed_payments_count).to eq(0)
      end
    end

    context 'unsubscribe from target' do
      before do
        SubscriptionManager.new(subscription: subscription).unsubscribe
      end

      specify do
        expect(stats_entry.subscriptions_count).to eq(0)
        expect(stats_entry.unsubscribers_count).to eq(1)
        expect(stats_entry.failed_payments_count).to eq(0)
      end
    end

    context 'failed payment' do
      before { StripeMock.start }
      after { StripeMock.stop }

      before do
        StripeMock.prepare_card_error(:card_declined)
        PaymentManager.new(user: user).pay_for(subscription)
      end

      specify do
        expect(stats_entry.subscriptions_count).to eq(0)
        expect(stats_entry.unsubscribers_count).to eq(0)
        expect(stats_entry.failed_payments_count).to eq(1)
      end
    end
  end

  describe '#increment_gross_sales_log_by' do
    it { expect { subject.increment_gross_sales_log_by }.not_to change { target_user.gross_sales }.from(0) }
    it { expect { subject.increment_gross_sales_log_by(1) }.to change { target_user.gross_sales }.from(0).to(1) }
  end

  describe '#increment_gross_contributions_log_by' do
    it { expect { subject.increment_gross_contributions_log_by }.not_to change { target_user.gross_contributions }.from(0) }
    it { expect { subject.increment_gross_contributions_log_by(1) }.to change { target_user.gross_contributions }.from(0).to(1) }
  end
end
