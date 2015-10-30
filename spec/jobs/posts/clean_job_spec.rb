require 'spec_helper'

describe Posts::CleanJob do
  describe '.perform' do
    subject(:perform) { described_class.perform }

    let(:user) { create_profile }
    let(:manager) { UserProfileManager.new(user) }

    before do
      UploadManager.new(user).create_pending_photos(transloadit_photo_data_params)
      PostManager.new(user: user).create_photo_post(title: 'test', message: 'test')
    end

    it { expect { perform }.not_to raise_error }

    context '2 months not passed after remove profile' do
      before { manager.delete_profile_page! }

      it { expect { perform }.not_to delete_record(Post) }
    end

    context '2 months passed since profile removed' do
      before do
        Timecop.freeze(2.month.ago) do
          manager.delete_profile_page!
          Upload.delete_all
        end
      end

      it { expect { perform rescue nil }.to delete_record(Post) }
    end

    context '2 months ago user removed and restored his profile and removed profile yesterday' do
      before do
        Timecop.freeze(2.month.ago) do
          manager.delete_profile_page!
          Upload.delete_all
          manager.create_profile_page
        end
        Timecop.freeze(1.day.ago) do
          manager.delete_profile_page!
        end
      end

      it { expect { perform }.not_to delete_record(Post) }
      it do
        Timecop.freeze(2.month.from_now) do
          expect { perform }.to delete_record(Post)
        end
      end
    end
  end
end
