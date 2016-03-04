class PostManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user: , post: nil)
    raise ArgumentError unless user.is_a?(User)
    @post = post
    @user = user
  end

  def show
    @post.hidden = false
    @post.save or fail_with! @post.errors
    @post.elastic_index_document
    user.denormalize_last_post_created_at!
    @post
  end

  def hide
    @post.hidden = true
    @post.save or fail_with! @post.errors
    @post.elastic_index_document
    user.denormalize_last_post_created_at!
    EventsManager.post_hidden(user: @user, post: @post)
    @post
  end

  # @param title [String]
  # @param message [String]
  # @param upload_ids [Array] ids to keep uploads on update
  # @return [Post]
  def update(title: :unset, message: , upload_ids: nil)
    fail_with! message: :empty if message.blank?

    title = nil if @post.status?
    message = CGI.escapeHTML(message)

    @post.title = title unless title == :unset
    @post.message = message
    @post.save or fail_with!(@post.errors)
    @post.elastic_index_document
    EventsManager.post_updated(user: @user, post: @post)
    FeedEventsManager.new(user: @user, target: @post).update_data(message: message)

    if upload_ids.is_a?(Array)
      @post.uploads.where.not(id: upload_ids).each do |upload|
        UploadManager.new(user).remove_upload(upload: upload, post: @post)
      end
    end

    @post
  end

  # @param message [String]
  # @param notify [String, nil]
  # @return [Post]
  def create_status_post(message: , notify: false)
    fail_with! message: :empty if message.blank?

    message = CGI.escapeHTML(message)

    @post = StatusPost.new(user: user, message: message).tap do |post|
      post.save or fail_with! post.errors
      post.elastic_index_document
      EventsManager.post_created(user: user, post: post)
      FeedEventsManager.new(user: user, target: post).create_status_event(message: message)
      user.pending_post.try(:destroy!)
      user.denormalize_last_post_created_at!(post.created_at)

      NotificationManager.delay.notify_post_created(post) if notify
    end
  end

  def create_audio_post(*args)
    if AudioPost.pending_uploads_for(user).count > 15
      fail_with! "You can't upload more than 15 tracks."
    end

    create_media_post(AudioPost, *args).tap do |post|
      FeedEventsManager.new(user: user, target: post).create_audio_event
      EventsManager.post_created(user: user, post: post)
    end
  end

  def create_video_post(title: nil, keyword_text: nil, message: nil, preview_url: nil, notify: false)
    videos = VideoPost.pending_uploads_for(user)
    fail_with! "You can't upload more than one video." if videos.many?

    video = videos.first

    create_media_post(VideoPost, title: title, keywords_text: keyword_text, message: message, notify: notify).tap do |post|
      video.preview_url = preview_url
      video.save!
      FeedEventsManager.new(user: user, target: post).create_video_event
      EventsManager.post_created(user: user, post: post)
    end
  end

  def create_photo_post(*args)
    if PhotoPost.pending_uploads_for(user).count > 15
      fail_with! "You can't upload more than 15 photos."
    end

    create_media_post(PhotoPost, *args).tap do |post|
      FeedEventsManager.new(user: user, target: post).create_photo_event
      EventsManager.post_created(user: user, post: post)
    end
  end

  def create_document_post(*args)
    if DocumentPost.pending_uploads_for(user).count > 5
      fail_with! "You can't upload more than 5 documents."
    end

    create_media_post(DocumentPost, *args).tap do |post|
      FeedEventsManager.new(user: user, target: post).create_document_event
      EventsManager.post_created(user: user, post: post)
    end
  end

  # @param message [String]
  # @param title [String]
  # @param keywords [String]
  # @return [PendingPost]
  def update_pending(message: nil, title: nil, keywords: nil)
    attributes = {}

    attributes[:message]  = CGI.escapeHTML(message) unless message.nil?
    attributes[:title]    = title                   unless title.nil?
    attributes[:keywords] = keywords                unless keywords.nil?

    if user.pending_post
      user.pending_post.update_attributes!(attributes)
    else
      PendingPost.create!(attributes.merge(user: user))
    end

    user.pending_post(true)
  end

  def cancel_pending_audios
    @user.pending_post_uploads.audios.destroy_all
    EventsManager.post_canceled(user: @user, post_type: 'AudioPost')
    make_pending_blank
  end

  def cancel_pending_videos
    @user.pending_post_uploads.videos.destroy_all
    EventsManager.post_canceled(user: @user, post_type: 'VideoPost')
    make_pending_blank
  end

  def cancel_pending_photos
    @user.pending_post_uploads.photos.destroy_all
    EventsManager.post_canceled(user: @user, post_type: 'PhotoPost')
    make_pending_blank
  end

  def cancel_pending_documents
    @user.pending_post_uploads.documents.destroy_all
    EventsManager.post_canceled(user: @user, post_type: 'DocumentPost')
    make_pending_blank
  end

  def delete(post)
    FeedEvent.where(target_type: 'Post', target_id: post.id).delete_all
    EventsManager.post_removed(user: user, post: post)

    number_of_deleted_posts = user.events
                                  .daily
                                  .where('action LIKE ?', '%_post_removed')
                                  .group('EXTRACT(HOUR FROM created_at)::integer')
                                  .count
                                  .select { |hour, count| count >= 5 }
    if number_of_deleted_posts.one? && number_of_deleted_posts[Time.now.hour] == 5
      ReportsMailer.delay.deleted_posts_too_often(user)
    end

    if Rails.env.production?
      UploadManager.delay.remove_post_uploads(ids: post.uploads.pluck(:id)) unless post.status?
    end
    post.elastic_delete_document
    post.destroy.tap do
      user.denormalize_last_post_created_at!
    end
  end

  # When all uploads removed we turn media posts into status posts
  # @return [StatusPost, nil]
  def turn_to_status_post
    fail_with! 'Post already is StatusPost' if @post.status?

    if @post.uploads.count.zero?
      @post.type = 'StatusPost'
      @post.title = nil
      @post.save or fail_with! @post.errors

      FeedEventsManager.new(user: user, target: @post).turn_to_status_event

      @post.elastic_index_document
      @post
    end
  end

  private

  def make_pending_blank
    update_pending message: "", title: "", keywords: ""
  end

  # @param post_class [Class]
  # @param title [String]
  # @param keywords_text [String]
  # @param message [String]
  def create_media_post(post_class, title: nil, keywords_text: nil, message: nil, notify: false)
    uploads = post_class.pending_uploads_for(user)

    fail_with! 'Please upload files' if uploads.empty?

    validate! do
      fail_with title:   :empty if title.blank?
      fail_with message: :empty if message.blank?

      fail_with title:         :too_long if title.to_s.length > 200
      fail_with keywords_text: :too_long if keywords_text.to_s.length > 200
    end

    message = CGI.escapeHTML(message)

    @post = post_class.new(user: user, message: message, title: title, keywords_text: keywords_text).tap do |post|
      post.save or fail_with! post.errors
      post.elastic_index_document
      uploads.each { |upload| post.uploads << upload }
      user.pending_post.try(:destroy!)
      user.denormalize_last_post_created_at!(post.created_at)

      NotificationManager.delay.notify_post_created(post) if notify
    end
  end
end
