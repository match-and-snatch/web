require 'spec_helper'

describe Posts::CleanJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:user) { create_profile }

    before do
      UploadManager.new(user).create_pending_photos(JSON.parse(transloadit_photo_data_params['transloadit']))
      PostManager.new(user: user).create_photo_post(title: 'test', message: 'test')
    end

    specify { expect { perform }.not_to raise_error }

    context '30 days not passed after remove profile' do
      before { UserProfileManager.new(user).delete_profile_page }

      it { expect { perform }.not_to change { Post.count } }
    end

    context '30 days passed since profile removed' do
      before do
        UserProfileManager.new(user).delete_profile_page
        Upload.delete_all
      end

      it do
        Timecop.freeze(1.month.from_now) do
          expect { perform rescue nil }.to change { Post.count }.from(1).to(0)
        end
      end
    end
  end
end
