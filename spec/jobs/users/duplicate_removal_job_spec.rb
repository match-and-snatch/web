require 'spec_helper'

describe Users::DuplicateRemovalJob do
  describe '#perform' do
    let!(:user) { create_user email: 'szinin@gmail.com' }

    specify do
      expect { subject.perform }.not_to change { user.reload.destroyed? }
    end

    context 'having duplicate' do
      let!(:duplicate) { create_user email: 'szinin_duplicate@gmail.com' }

      before do
        duplicate.email = 'szinin@gmail.com'
        duplicate.save!
      end

      specify do
        subject.perform
        expect { user.reload }.not_to raise_error
      end

      specify do
        subject.perform
        expect { duplicate.reload }.to raise_error
      end

      context 'with subscription' do
        let!(:user) { create_profile email: 'szinin@gmail.com' }
        let!(:another_duplicate) { create_user email: 'szinin_another@gmail.com' }

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

        specify do
          subject.perform
          expect { another_duplicate.reload }.to raise_error
        end
      end
    end
  end
end
