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
    save_or_die! @comment
    EventsManager.comment_mark_as_visible(user: @user, comment: @comment)
    @comment
  end

  def hide
    @comment.hidden = true
    save_or_die! @comment
    EventsManager.comment_mark_as_hidden(user: @user, comment: @comment)
    @comment
  end

  # @param message [String]
  # @return [Comment]
  def create(message: , mentions: nil)
    @post or fail_with! post: :empty

    unless @user.subscribed_to?(@post.user) || @user == @post.user
      raise ArgumentError, "Can't comment on non subscribed user posts"
    end

    comment = Comment.new(post: @post, user: @user, post_user: @post.user, parent: @parent, message: message, mentions: mentions)
    save_or_die! comment
    EventsManager.comment_created(user: @user, comment: comment)

    comment.mentioned_users.find_each do |user|
      PostsMailer.delay.mentioned(comment, user)
    end

    comment
  end
end
