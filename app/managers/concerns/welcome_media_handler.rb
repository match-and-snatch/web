module Concerns::WelcomeMediaHandler
  # @param transloadit_data [Hash]
  # @return [User]
  def update_welcome_media(transloadit_data)
    upload = UploadManager.new(user).create_welcome_media(transloadit_data)
    clear_old_welcome_uploads!(current_upload: upload)
    EventsManager.welcome_media_added(user: user, media: upload)
    user
  end

  # @return [User]
  def remove_welcome_media!
    clear_old_welcome_uploads!(clear_all: true)
    EventsManager.welcome_media_removed(user: user)
    user
  end

  # @return [User]
  def hide_welcome_media
    fail_with! 'Welcome media already hidden' if user.welcome_media_hidden?

    user.welcome_media_hidden = true
    save_or_die! user
  end

  # @return [User]
  def show_welcome_media
    fail_with! 'Welcome media already visible' unless user.welcome_media_hidden?

    user.welcome_media_hidden = false
    save_or_die! user
  end

  # @param ids [Array]
  def self.hide_welcome_media(ids = [])
    raise BulkEmptySetError, 'No users selected' if ids.blank?

    ActiveRecord::Base.transaction do
      User.where(id: ids, welcome_media_hidden: false).find_each do |user|
        UserProfileManager.new(user).hide_welcome_media
      end
    end
  end

  # @param ids [Array]
  def self.show_welcome_media(ids = [])
    raise BulkEmptySetError, 'No users selected' if ids.blank?

    ActiveRecord::Base.transaction do
      User.where(id: ids, welcome_media_hidden: true).find_each do |user|
        UserProfileManager.new(user).show_welcome_media
      end
    end
  end

  private

  # @param current_upload [Video, Audio]
  # @param clear_all [Boolean]
  def clear_old_welcome_uploads!(current_upload: nil, clear_all: false)
    if current_upload.present?
      Upload.users.where(uploadable_id: user.id, type: current_upload.class.name).where.not(id: current_upload.id).each do |upload|
        upload.delete
        EventsManager.upload_removed(user: user, upload: upload)
      end
    end
    if clear_all || current_upload.is_a?(Video)
      Audio.users.where(uploadable_id: user.id).each do |audio|
        audio.delete
        EventsManager.upload_removed(user: user, upload: audio)
      end
    end
    if clear_all || current_upload.is_a?(Audio)
      Video.users.where(uploadable_id: user.id).each do |video|
        video.delete
      end
    end
  end
end
