require 'spec_helper'

describe Concerns::WelcomeMediaHandler do
  let(:ids) { [] }
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }

  subject(:handler) { described_class }

  describe '.hide_welcome_media' do
    it { expect { handler.hide_welcome_media }.to raise_error(BulkEmptySetError, /No users selected/) }

    context 'ids are provided' do
      let(:ids) { [user1.id, user2.id] }

      it { expect { handler.hide_welcome_media(ids) }.to change { user1.reload.welcome_media_hidden? }.from(false).to(true) }
      it { expect { handler.hide_welcome_media(ids) }.to change { user2.reload.welcome_media_hidden? }.from(false).to(true) }

      context 'welcome media is hidden' do
        let(:user3) { create(:user, welcome_media_hidden: true) }
        let(:ids) { [user1.id, user2.id, user3.id] }

        it { expect { handler.hide_welcome_media(ids) }.not_to raise_error }
        it { expect { handler.hide_welcome_media(ids) }.not_to change { user3.reload.welcome_media_hidden? }.from(true) }
      end
    end
  end

  describe '.show_welcome_media' do
    it { expect { handler.show_welcome_media }.to raise_error(BulkEmptySetError, /No users selected/) }

    context 'ids are provided' do
      let(:user1) { create(:user, welcome_media_hidden: true) }
      let(:user2) { create(:user, welcome_media_hidden: true) }
      let(:ids) { [user1.id, user2.id] }

      it { expect { handler.show_welcome_media(ids) }.to change { user1.reload.welcome_media_hidden? }.from(true).to(false) }
      it { expect { handler.show_welcome_media(ids) }.to change { user2.reload.welcome_media_hidden? }.from(true).to(false) }

      context 'welcome media is visible' do
        let(:user3) { create(:user) }
        let(:ids) { [user1.id, user2.id, user3.id] }

        it { expect { handler.show_welcome_media(ids) }.not_to raise_error }
        it { expect { handler.show_welcome_media(ids) }.not_to change { user3.reload.welcome_media_hidden? }.from(false) }
      end
    end
  end
end
