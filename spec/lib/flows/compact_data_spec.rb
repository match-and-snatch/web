require 'spec_helper'

describe Flows::CompactData do
  describe '.pack' do
    subject(:pack) { described_class.pack(record) }
    let(:record) { create_user }

    it { is_expected.to be_a Flows::CompactData }
  end

  describe '#unpack' do
    subject(:packed_data) { described_class.pack(record) }
    subject(:unpacked_data) { packed_data.unpack }

    context 'persisted record' do
      let(:record) { create_user }

      it { is_expected.to be_a(User) }
      it { is_expected.to be_persisted }
      its(:id) { is_expected.to eq(record.id) }
    end

    context 'removed record' do
      let(:record) { create_user(email: 'tester@sample.ru').tap(&:destroy) }

      it { is_expected.to be_a(User) }
      it { is_expected.not_to be_persisted }
      its(:id) { is_expected.to eq(record.id) }
      its(:email) { is_expected.to eq('tester@sample.ru') }
    end
  end
end