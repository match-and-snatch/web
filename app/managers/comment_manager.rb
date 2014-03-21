class CommentManager < BaseManager

  # @param user [User]
  # @param post [Post]
  def initialize(user: user, post: post)
    @user = user
    @post = post
  end

  # @param message [String]
  # @return [Comment]
  def create(message)
    unless @user.subscribed_to?(@post.user)
      raise ArgumentError, "Can't comment on non subscribed user posts"
    end

    comment = Comment.new(post: @post, user: @user, message: message)
    comment.save or fail_with!(comment.errors)
    comment
  end
end