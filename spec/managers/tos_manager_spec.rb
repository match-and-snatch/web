require 'spec_helper'

describe TosManager do
  subject(:manager) { described_class.new(tos_version) }
  let(:tos_version) { nil }

  describe '#create' do
    it { expect { manager.create(tos: 'ToS', privacy_policy: 'PP') }.to create_record(TosVersion).matching(tos: 'ToS', privacy_policy: 'PP') }

    context 'empty ToS specified' do
      it { expect { manager.create(tos: '', privacy_policy: 'PP') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(tos: t_error(:empty)) } }
      it { expect { manager.create(tos: '', privacy_policy: 'PP') rescue nil }.not_to create_record(TosVersion) }
    end

    context 'empty Privacy Policy specified' do
      it { expect { manager.create(tos: 'ToS', privacy_policy: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(privacy_policy: t_error(:empty)) } }
      it { expect { manager.create(tos: 'Tos', privacy_policy: '') rescue nil }.not_to create_record(TosVersion) }
    end
  end

  describe '#update' do
    let(:tos_version) { create(:tos_version) }

    it { expect { manager.update(tos: 'ToS', privacy_policy: 'PP') }.to change { tos_version.tos }.from(tos_version.tos).to('ToS') }
    it { expect { manager.update(tos: 'ToS', privacy_policy: 'PP') }.to change { tos_version.privacy_policy }.from(tos_version.privacy_policy).to('PP') }

    context 'empty ToS specified' do
      it { expect { manager.update(tos: '', privacy_policy: 'PP') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(tos: t_error(:empty)) } }
      it { expect { manager.update(tos: '', privacy_policy: 'PP') rescue nil }.not_to change { tos_version.tos }.from(tos_version.tos) }
    end

    context 'empty Privacy Policy specified' do
      it { expect { manager.update(tos: 'ToS', privacy_policy: '') }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(privacy_policy: t_error(:empty)) } }
      it { expect { manager.update(tos: 'Tos', privacy_policy: '') rescue nil }.not_to change { tos_version.privacy_policy }.from(tos_version.privacy_policy) }
    end
  end

  describe '#publish' do
    let(:tos_version) { create(:tos_version) }

    it { expect { manager.publish }.to change { tos_version.published? }.from(false).to(true) }

    context 'published version' do
      let(:tos_version) { create(:tos_version, :published) }

      it { expect { manager.publish }.to raise_error(ManagerError, /Already published/) }
      it { expect { manager.publish rescue nil }.not_to change { tos_version.published? }.from(true) }
    end

    context 'previous version is accepted' do
      let(:user) { create(:user, tos_accepted: true) }
      let(:old_tos_version) { create(:tos_version, :published) }
      let!(:acceptance) { user.tos_acceptances.create!(tos_version: old_tos_version) }

      it { expect { manager.publish }.to change { user.reload.tos_accepted? }.from(true).to(false) }
      it { expect { manager.publish }.not_to delete_record(TosAcceptance).matching(id: acceptance.id) }
    end
  end

  describe '#reset_tos_acceptance' do
    let(:user) { create(:user, tos_accepted: true) }
    let(:tos_version) { create(:tos_version, :published) }
    let!(:acceptance) { user.tos_acceptances.create!(tos_version: tos_version) }

    it { expect { manager.reset_tos_acceptance }.to change { user.reload.tos_accepted? }.from(true).to(false) }
    it { expect { manager.reset_tos_acceptance }.to delete_record(TosAcceptance).matching(id: acceptance.id) }
  end
end
