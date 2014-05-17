class CommentManager < BaseManager

  # @param user [User]
  # @param post [Post]
  def initialize(user: user, post: nil, parent: nil, comment: nil)
    @user = user
    @post = post
    @parent = parent
    @comment = comment
  end

  def show
    @comment.hidden = false
    @comment.save or fail_with! @comment.errors
    @comment
  end

  def hide
    @comment.hidden = true
    @comment.save or fail_with! @comment.errors
    @comment
  end

  # @param message [String]
  # @return [Comment]
  def create(message: message, mentions: nil)
    @post or fail_with! post: :empty

    unless @user.subscribed_to?(@post.user) || @user == @post.user
      raise ArgumentError, "Can't comment on non subscribed user posts"
    end

    comment = Comment.new(post: @post, user: @user, post_user: @post.user, parent: @parent, message: message, mentions: mentions)
    comment.save or fail_with!(comment.errors)

    comment.mentioned_users.find_each do |user|
      PostsMailer.delay.mentioned(comment, user)
    end

    comment
  end
end
