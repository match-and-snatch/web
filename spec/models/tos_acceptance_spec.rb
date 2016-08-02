require 'spec_helper'

describe TosAcceptance do
  describe '.active' do
    let(:user) { create(:user) }
    let(:tos_version) { create(:tos_version, :published) }
    let!(:acceptance) { user.tos_acceptances.create!(tos_version: tos_version) }

    it { expect(described_class.active).to eq([acceptance]) }

    context 'recently version present' do
      let!(:latest_tos_version) { create(:tos_version, :published, published_at: 5.minutes.from_now) }

      it { expect(described_class.active).to eq([]) }

      context 'accepted tos' do
        let!(:latest_acceptance) { user.tos_acceptances.create!(tos_version: latest_tos_version) }

        it { expect(described_class.active).to eq([latest_acceptance]) }
      end
    end
  end
end
