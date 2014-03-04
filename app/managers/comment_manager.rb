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
    comment = Comment.new(post: @post, user: @user, message: message)
    comment.save or fail_with!(comment.errors)
    comment
  end
end