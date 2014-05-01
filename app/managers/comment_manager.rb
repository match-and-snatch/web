class CommentManager < BaseManager

  # @param user [User]
  # @param post [Post]
  def initialize(user: user, post: post, parent: nil)
    @user = user
    @post = post
    @parent = parent
  end

  # @param message [String]
  # @return [Comment]
  def create(message: message, mentions: nil)
    unless @user.subscribed_to?(@post.user) || @user == @post.user
      raise ArgumentError, "Can't comment on non subscribed user posts"
    end

    comment = Comment.new(post: @post, user: @user, post_user: @post.user, parent: @parent, message: message, mentions: mentions)
    comment.save or fail_with!(comment.errors)

    comment.mentioned_users.find_each do |user|
      PostsMailer.mentioned(comment, user).deliver
    end

    comment
  end
end