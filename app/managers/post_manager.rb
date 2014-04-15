class PostManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user: user)
    raise ArgumentError unless user.is_a?(User)
    @user = user
  end

  # @param message [String]
  # @return [Post]
  def create(message)
    fail_with! message: :empty if message.blank?

    Post.new(user: user, message: message).tap do |post|
      post.save or fail_with! post.errors
      user.pending_post_uploads.each { |upload| post.uploads << upload }
      user.pending_post.try(:destroy!)
    end
  end

  def create_video_post(title: nil, keywords_text: nil, message: nil)
    if user.pending_post_uploads.videos.many?
      fail_with! "You can't upload more than one video."
    end

    create_media_post(title: title,
                      keywords_text: keywords_text,
                      message: message,
                      uploads: user.pending_post_uploads.videos)
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

  def create_media_post(title: nil, keywords_text: nil, message: nil, uploads: [])
    fail_with! 'Please upload files' if uploads.empty?

    validate! do
      fail_with title:   :empty if title.blank?
      fail_with message: :empty if message.blank?

      fail_with title:         :too_long if title.to_s.length > 200
      fail_with keywords_text: :too_long if keywords_text.to_s.length > 200
    end

    Post.new(user: user, message: message, title: title, keywords_text: keywords_text).tap do |post|
      post.save or fail_with! post.errors
      uploads.each { |upload| post.uploads << upload }
      user.pending_post.try(:destroy!)
    end
  end
end