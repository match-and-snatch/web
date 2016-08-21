describe Concerns::SubscriberBenefitsHandler do
  let(:ids) { [] }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  subject(:handler) { described_class }

  describe '.hide_benefits' do
    it { expect { handler.hide_benefits }.to raise_error(BulkEmptySetError, /No users selected/) }

    context 'ids are provided' do
      let(:ids) { [user1.id, user2.id] }

      it { expect { handler.hide_benefits(ids) }.to change { user1.reload.benefits_visible? }.from(true).to(false) }
      it { expect { handler.hide_benefits(ids) }.to change { user2.reload.benefits_visible? }.from(true).to(false) }

      context 'benefits are hidden' do
        let(:user3) { create(:user, benefits_visible: false) }
        let(:ids) { [user1.id, user2.id, user3.id] }

        it { expect { handler.hide_benefits(ids) }.not_to raise_error }
        it { expect { handler.hide_benefits(ids) }.not_to change { user3.reload.benefits_visible? }.from(false) }
      end
    end
  end

  describe '.show_benefits' do
    it { expect { handler.show_benefits }.to raise_error(BulkEmptySetError, /No users selected/) }

    context 'ids are provided' do
      let(:user1) { create(:user, benefits_visible: false) }
      let(:user2) { create(:user, benefits_visible: false) }
      let(:ids) { [user1.id, user2.id] }

      it { expect { handler.show_benefits(ids) }.to change { user1.reload.benefits_visible? }.from(false).to(true) }
      it { expect { handler.show_benefits(ids) }.to change { user2.reload.benefits_visible? }.from(false).to(true) }

      context 'benefits are visible' do
        let(:user3) { create(:user) }
        let(:ids) { [user1.id, user2.id, user3.id] }

        it { expect { handler.show_benefits(ids) }.not_to raise_error }
        it { expect { handler.show_benefits(ids) }.not_to change { user3.reload.benefits_visible? }.from(true) }
      end
    end
  end
end
