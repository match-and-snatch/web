require 'spec_helper'

describe ChartsPresenter do
  describe '#filter_hash' do
    specify { expect(subject.filter_hash).to eq described_class::FILTER_HASH }
  end

  describe '#chart_data' do
    let(:event_date) { Event.where(action: 'registered').first.created_at.to_date.to_time.utc.beginning_of_day.to_i }
    before { create_user }

    specify do
      expect(described_class.new(graph_type: 'registered').chart_data).to eq([{ x: event_date, y: 1 }])
    end

    context 'no action specified' do
      specify { expect(subject.chart_data).to eq([]) }
    end

    context 'no events for action' do
      specify { expect(described_class.new(graph_type: 'abaracadabara').chart_data).to eq([]) }
    end
  end
end
