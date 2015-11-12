require 'spec_helper'

describe 'delete_record' do
  context 'record created' do
    let!(:user) { create_user }

    it { expect { user.destroy }.to delete_record(User) }
    it { expect { user.destroy }.to delete_record(User).once }
    it { expect { user.destroy }.not_to delete_record(Post) }

    context 'matching arguments' do
      let!(:user) { create_user email: 'szinin@gmail.com' }

      it { expect { user.destroy }.to delete_record(User).matching(email: 'szinin@gmail.com') }
      it { expect { user.destroy }.not_to delete_record(User).matching(email: 'another@gmail.com') }
    end

    context 'multiple users' do
      let!(:second_user) { create_user email: 'second@user.com' }

      it do
        expect do
          user.destroy
          second_user.destroy
        end.to delete_record(User).exactly(2.times)
      end

      it do
        expect do
          user.destroy
          second_user.destroy
        end.not_to delete_record(User).exactly(3.times)
      end

      it do
        expect do
          user.destroy
          second_user.destroy
        end.not_to delete_record(User).once
      end

      it do
        expect do
          user.destroy
          second_user.destroy
        end.to delete_record(User)
      end
    end
  end
end
