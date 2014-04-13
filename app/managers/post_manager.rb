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

  # @param message [String]
  # @param title [String]
  # @param keywords [String]
  # @return [PendingPost]
  def update_pending(message: nil, title: nil, keywords: nil)
    attributes = { message: message, title: title, keywords: keywords }

    if user.pending_post
      user.pending_post.update_attributes!(attributes)
    else
      PendingPost.create!(attributes.merge(user: user))
    end

    user.pending_post(true)
  end
end