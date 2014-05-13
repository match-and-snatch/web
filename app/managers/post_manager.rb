class PostManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user: user, post: nil)
    raise ArgumentError unless user.is_a?(User)
    @post = post
    @user = user
  end

  def show
    @post.hidden = false
    @post.save or fail_with! @post.errors
    @post
  end

  def hide
    @post.hidden = true
    @post.save or fail_with! @post.errors
    @post
  end

  def update(title: title, message: message)
    fail_with! message: :empty if message.blank?

    @post.title = title
    @post.message = message
    @post.save or fail_with!(@post.errors)

    @post
  end

  # @param message [String]
  # @return [Post]
  def create_status_post(message: message)
    fail_with! message: :empty if message.blank?

    message = CGI.escapeHTML(message)

    StatusPost.new(user: user, message: message).tap do |post|
      post.save or fail_with! post.errors
      StatusFeedEvent.create! subscription_target_user: user, target: post, data: {message: message}
      user.pending_post.try(:destroy!)
    end
  end

  def create_audio_post(*args)
    if AudioPost.pending_uploads_for(user).count > 15
      fail_with! "You can't upload more than 15 tracks."
    end

    create_media_post(AudioPost, *args).tap do |post|
      AudioFeedEvent.create! subscription_target_user: user, target: post
    end
  end

  def create_video_post(*args)
    if VideoPost.pending_uploads_for(user).many?
      fail_with! "You can't upload more than one video."
    end

    create_media_post(VideoPost, *args).tap do |post|
      VideoFeedEvent.create! subscription_target_user: user, target: post
    end
  end

  def create_photo_post(*args)
    if PhotoPost.pending_uploads_for(user).count > 15
      fail_with! "You can't upload more than 15 photos."
    end

    create_media_post(PhotoPost, *args).tap do |post|
      PhotoFeedEvent.create! subscription_target_user: user, target: post
    end
  end

  def create_document_post(*args)
    if DocumentPost.pending_uploads_for(user).count > 5
      fail_with! "You can't upload more than 5 documents."
    end

    create_media_post(DocumentPost, *args).tap do |post|
      DocumentFeedEvent.create! subscription_target_user: user, target: post
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
    make_pending_blank
  end

  def cancel_pending_videos
    @user.pending_post_uploads.videos.destroy_all
    make_pending_blank
  end

  def cancel_pending_photos
    @user.pending_post_uploads.photos.destroy_all
    make_pending_blank
  end

  def cancel_pending_documents
    @user.pending_post_uploads.documents.destroy_all
    make_pending_blank
  end

  def delete(post)
    FeedEvent.where(target_type: 'Post', target_id: post.id).delete_all
    post.destroy
  end

  private

  def make_pending_blank
    update_pending message: "", title: "", keywords: ""
  end

  # @param post_class [Class]
  # @param title [String]
  # @param keywords_text [String]
  # @param message [String]
  def create_media_post(post_class, title: nil, keywords_text: nil, message: nil)
    uploads = post_class.pending_uploads_for(user)

    fail_with! 'Please upload files' if uploads.empty?

    validate! do
      fail_with title:   :empty if title.blank?
      fail_with message: :empty if message.blank?

      fail_with title:         :too_long if title.to_s.length > 200
      fail_with keywords_text: :too_long if keywords_text.to_s.length > 200
    end

    message = CGI.escapeHTML(message)

    post_class.new(user: user, message: message, title: title, keywords_text: keywords_text).tap do |post|
      post.save or fail_with! post.errors
      uploads.each { |upload| post.uploads << upload }
      user.pending_post.try(:destroy!)
    end
  end
end
