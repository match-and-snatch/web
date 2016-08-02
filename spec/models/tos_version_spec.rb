require 'spec_helper'

describe TosVersion do
  let!(:tos_version) { create(:tos_version) }

  describe '.published' do
    subject { described_class }

    it { expect(subject.published).to eq([]) }

    context 'published version is present' do
      let!(:published_tos_version) { create(:tos_version, :published) }

      it { expect(subject.published).to eq([published_tos_version]) }
    end
  end

  describe '.active' do
    subject { described_class }

    it { expect(subject.active).to be_nil }

    context 'published version is present' do
      let!(:published_tos_version) { create(:tos_version, :published) }

      it { expect(subject.active).to eq(published_tos_version) }

      context 'multiple published versions are present', freeze: 1.minute.from_now do
        let!(:old_tos_version) { create(:tos_version, :published, published_at: 5.minutes.ago) }
        let!(:latest_tos_version) { create(:tos_version, :published, published_at: Time.zone.now) }

        it 'returns latest version' do
          expect(subject.active).to eq(latest_tos_version)
        end
      end
    end
  end

  describe '#active?' do
    it { expect(tos_version.active?).to eq(false) }

    context 'version is published' do
      before { TosManager.new(tos_version).publish }

      it { expect(tos_version.active?).to eq(true) }
    end
  end

  describe '#published?' do
    it { expect(tos_version.published?).to eq(false) }
    it { expect(tos_version.published_at).to be_nil }

    context 'published version' do
      let!(:published_tos_version) { create(:tos_version, :published) }

      it { expect(published_tos_version.published?).to eq(true) }
      it { expect(published_tos_version.published_at).not_to be_nil }
    end
  end
end
