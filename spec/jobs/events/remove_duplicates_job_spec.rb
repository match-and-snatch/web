require 'spec_helper'

describe Events::RemoveDuplicatesJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:user) { create(:user) }
    let!(:event) { EventsManager.user_registered(user: user) }

    specify { expect { perform }.not_to raise_error }

    context 'No duplicates' do
      specify do
        expect { perform }.not_to change { user.events.where(action: 'registered').count }.from(1)
      end
    end

    context 'One duplicate' do
      before do
        EventsManager.user_registered(user: user) do |event|
          event.created_at = user.created_at
          event.updated_at = user.created_at
        end
      end

      specify do
        expect { perform }.to change { user.events.where(action: 'registered').count }.from(2).to(1)
      end

      context 'More than one duplicates' do
        before do
          EventsManager.user_registered(user: user) do |event|
            event.created_at = user.created_at
            event.updated_at = user.created_at
          end
        end

        specify do
          expect { perform }.to change { user.events.where(action: 'registered').count }.from(3).to(1)
        end
      end
    end
  end
end
