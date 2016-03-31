require 'spec_helper'

describe Events::ClearJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:user) { create(:user) }
    let(:event) do
      Timecop.freeze(3.months.ago) do
        EventsManager.user_logged_in(user: user)
      end
    end

    it { expect { perform }.not_to raise_error }
    it { expect { perform }.to delete_record(Event).matching(id: event.id) }

    context do
      let(:event) { EventsManager.user_logged_in(user: user) }

      it 'does not touch new events' do
        expect { perform }.not_to delete_record(Event).matching(id: event.id)
      end
    end

    context do
      let(:event) do
        Timecop.freeze(3.months.ago) do
          EventsManager.account_locked(user: user, type: 'billing', reason: 'cc_update_limit')
        end
      end

      it 'does not touch some events' do
        expect { perform }.not_to delete_record(Event).matching(id: event.id)
      end
    end
  end
end
