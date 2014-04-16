class PostManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user: user)
    raise ArgumentError unless user.is_a?(User)
    @user = user
  end

  # @param message [String]
  # @return [Post]
  def create_status_post(message: message)
    fail_with! message: :empty if message.blank?

    StatusPost.new(user: user, message: message).tap do |post|
      post.save or fail_with! post.errors
      user.pending_post.try(:destroy!)
    end
  end

  def create_audio_post(*args)
    if AudioPost.pending_uploads_for(user).count > 15
      fail_with! "You can't upload more than 15 tracks."
    end

    create_media_post AudioPost, *args
  end

  def create_video_post(*args)
    if VideoPost.pending_uploads_for(user).many?
      fail_with! "You can't upload more than one video."
    end

    create_media_post VideoPost, *args
  end

  def create_photo_post(*args)
    if PhotoPost.pending_uploads_for(user).count > 15
      fail_with! "You can't upload more than 15 photos."
    end

    create_media_post PhotoPost, *args
  end
  
  def create_document_post(*args)
    if DocumentPost.pending_uploads_for(user).count > 5
      fail_with! "You can't upload more than 5 documents."
    end

    create_media_post DocumentPost, *args
  end

  # @param message [String]
  # @param title [String]
  # @param keywords [String]
  # @return [PendingPost]
  def update_pending(message: nil, title: nil, keywords: nil)
    attributes = {}

    attributes[:message]  = message  unless message.nil?
    attributes[:title]    = title    unless title.nil?
    attributes[:keywords] = keywords unless keywords.nil?

    if user.pending_post
      user.pending_post.update_attributes!(attributes)
    else
      PendingPost.create!(attributes.merge(user: user))
    end

    user.pending_post(true)
  end

  private

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

    post_class.new(user: user, message: message, title: title, keywords_text: keywords_text).tap do |post|
      post.save or fail_with! post.errors
      uploads.each { |upload| post.uploads << upload }
      user.pending_post.try(:destroy!)
    end
  end
end