require 'spec_helper'

describe Users::DuplicateRemovalJob do
  describe '#perform' do
    let!(:user) { create(:user, email: 'szinin@gmail.com') }

    it { expect { subject.perform }.not_to change { user.reload.destroyed? } }

    context 'having duplicate' do
      let!(:duplicate) { create(:user, email: 'szinin_duplicate@gmail.com') }

      before do
        duplicate.email = 'szinin@gmail.com'
        duplicate.save!
      end

      specify do
        subject.perform
        expect { user.reload }.not_to raise_error
      end

      it { expect { subject.perform }.to delete_record(User).matching(id: duplicate.id) }

      context 'with subscription' do
        let!(:user) { create(:user, :profile_owner, email: 'szinin@gmail.com') }
        let!(:another_duplicate) { create(:user, email: 'szinin_another@gmail.com') }

        before do
          another_duplicate.email = 'szinin@gmail.com'
          another_duplicate.save!
        end

        before do
          SubscriptionManager.new(subscriber: duplicate).subscribe_to(user)
        end

        specify do
          subject.perform
          expect { user.reload }.not_to raise_error
        end

        specify do
          subject.perform
          expect { duplicate.reload }.not_to raise_error
        end

        it { expect { subject.perform }.to delete_record(User).matching(id: another_duplicate.id) }
      end
    end
  end
end
