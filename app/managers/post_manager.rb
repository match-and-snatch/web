class PostManager < BaseManager

  # @param user [User]
  def initialize(user: user)
    raise ArgumentError unless user.is_a?(User)
    @user = user
  end

  # @param message [String]
  # @return [Post]
  def create(message)
    fail_with! message: :empty if message.blank?

    Post.new(user: @user, message: message).tap do |post|
      post.save or fail_with! post.errors
      @user.pending_post_uploads.each { |upload| post.uploads << upload }
    end
  end
end