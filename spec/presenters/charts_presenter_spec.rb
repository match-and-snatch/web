require 'spec_helper'

describe ChartsPresenter do
  describe '#filter_hash' do
    specify { expect(subject.filter_hash).to eq described_class::FILTER_HASH }
  end

  describe '#chart_data' do
    let(:event_date) { Event.where(action: 'registered').first.created_at.utc.beginning_of_day.to_i }
    let!(:profile_owner) { create_profile email: 'profile_owner@mail.com', cost: 5 }

    specify do
      expect(described_class.new(graph_type: 'registered').chart_data).to eq([{ x: event_date, y: 1 }])
    end

    context 'no action specified' do
      specify { expect(subject.chart_data).to eq([]) }
    end

    context 'no events for action' do
      specify { expect(described_class.new(graph_type: 'abaracadabara').chart_data).to eq([]) }
    end

    context 'gross sales graph with payments' do
      let(:subscriber) { create_user email: 'subscriber@mail.com' }
      let(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_to(profile_owner) }
      let(:payment_date) { Payment.last.created_at.utc.beginning_of_month.to_i }

      before { StripeMock.start }
      after { StripeMock.stop }

      context 'this year payments' do
        before do
          PaymentManager.new(user: subscriber).pay_for(subscription)
        end

        specify { expect(described_class.new(graph_type: 'gross_sales').chart_data).to eq([{ x: payment_date, y: 5.99 }]) }
      end

      context 'next year payments' do
        before do
          Timecop.freeze Date.new(Time.zone.now.year + 1, 01, 02) do
            PaymentManager.new(user: subscriber).pay_for(subscription)
          end
        end

        specify do
          expect(described_class.new(graph_type: 'gross_sales').chart_data).to eq([{ x: payment_date, y: 5.99 }])
        end
      end
    end

    context 'gross sales graph without payments' do
      specify { expect(described_class.new(graph_type: 'gross_sales').chart_data).to eq([]) }
    end
  end
end
