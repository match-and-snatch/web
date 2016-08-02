require 'spec_helper'

describe TosManager do
  subject(:manager) { described_class.new(tos_version) }
  let(:tos_version) { nil }

  describe '#create' do
    it { expect { manager.create(tos: 'ToS') }.to create_record(TosVersion).matching(tos: 'ToS') }
  end

  describe '#publish' do
    let(:tos_version) { create(:tos_version) }

    it { expect { manager.publish }.to change { tos_version.published? }.from(false).to(true) }

    context 'published version' do
      let(:tos_version) { create(:tos_version, :published) }

      it { expect { manager.publish }.to raise_error(ManagerError, /Already published/) }
      it { expect { manager.publish rescue nil }.not_to change { tos_version.published? }.from(true) }
    end
  end

  describe '#reset_tos_acceptance' do
    let(:user) { create(:user, tos_accepted: true) }

    it { expect { manager.reset_tos_acceptance(tos: 'ToS') }.to change { user.reload.tos_accepted? }.from(true).to(false) }
    it { expect { manager.reset_tos_acceptance(tos: 'ToS') }.to create_record(TosVersion).matching(tos: 'ToS') }

    context 'empty ToS specified' do
      it { expect { manager.reset_tos_acceptance(tos: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(tos: t_error(:empty)) } }
      it { expect { manager.reset_tos_acceptance(tos: '') rescue nil }.not_to create_record(TosVersion) }
    end
  end
end
