describe ChartsPresenter do
  describe '#filter_hash' do
    specify { expect(subject.filter_hash).to eq described_class::FILTER_HASH }
  end

  describe '#chart_data' do
    let!(:profile_owner) { create(:user, :profile_owner, email: 'profile_owner@mail.com', cost: 5_00, subscription_cost: 6_99, subscription_fees: 1_99) }
    let!(:event_date) { EventsManager.user_registered(user: profile_owner).created_at.utc.beginning_of_day.to_i }

    specify do
      expect(described_class.new(graph_type: 'registered').chart_data).to eq([{x: event_date, y: 1}])
    end

    context 'no action specified' do
      specify { expect(subject.chart_data).to eq([]) }
    end

    context 'no events for action' do
      specify { expect(described_class.new(graph_type: 'abaracadabara').chart_data).to eq([]) }
    end

    context 'gross sales graph with payments' do
      let(:subscriber) { create(:user, email: 'subscriber@mail.com') }
      let(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_to(profile_owner) }
      let(:payment_date) { Payment.last.created_at.utc.beginning_of_month.to_i }

      before { StripeMock.start }
      after { StripeMock.stop }

      context 'this year payments' do
        before do
          PaymentManager.new(user: subscriber).pay_for(subscription)
        end

        specify { expect(described_class.new(graph_type: 'gross_sales').chart_data).to eq([{x: payment_date, y: 6.99}]) }
      end

      context 'next year payments' do
        before do
          Timecop.freeze Date.new(Time.zone.now.year + 1, 01, 02) do
            PaymentManager.new(user: subscriber).pay_for(subscription)
          end
        end

        specify do
          expect(described_class.new(graph_type: 'gross_sales').chart_data).to eq([{x: payment_date, y: 6.99}])
        end
      end
    end

    context 'gross sales graph without payments' do
      specify { expect(described_class.new(graph_type: 'gross_sales').chart_data).to eq([]) }
    end
  end
end
