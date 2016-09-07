require 'spec_helper'

describe TosAcceptance do
  describe '.active' do
    let(:user) { create(:user) }
    let(:tos_version) { create(:tos_version, :published) }
    let!(:acceptance) { user.tos_acceptances.create!(tos_version: tos_version) }

    it { expect(described_class.active).to eq([acceptance]) }

    context 'no active version present' do
      let!(:tos_version) { create(:tos_version, :published, active: false) }

      it { expect(described_class.active).to eq([]) }
    end
  end
end
