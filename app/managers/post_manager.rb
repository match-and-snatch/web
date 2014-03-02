class PostManager < BaseManager

  # @param user [User]
  def initialize(user)
    raise ArgumentError unless user.is_a?(User)
    @user = user
  end

  # @param message [String]
  # @return [Post]
  def create(message)
    fail_with! message: :empty if message.blank?

    post = Post.new(user: @user, message: message)
    post.save or fail_with! post.errors
    post
  end
end