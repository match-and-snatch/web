class CommentManager < BaseManager

  # @param user [User]
  # @param post [Post]
  def initialize(user: , post: nil, parent: nil, comment: nil)
    @user = user
    @post = post
    @parent = parent
    @comment = comment
  end

  def show
    @comment.hidden = false
    save_or_die! @comment
    EventsManager.comment_shown(user: @user, comment: @comment)
    @comment
  end

  def hide
    @comment.hidden = true
    save_or_die! @comment
    EventsManager.comment_hidden(user: @user, comment: @comment)
    @comment
  end

  # @param message [String]
  # @param mentions [Hash]
  # @return [Comment]
  def create(message: , mentions: nil)
    @post or fail_with! post: :empty

    unless @user.subscribed_to?(@post.user) || @user == @post.user
      raise ArgumentError, "Can't comment on non subscribed user posts"
    end

    comment = Comment.new(post: @post, user: @user, post_user: @post.user, parent: @parent, message: strip_tags(message), mentions: mentions)
    save_or_die! comment
    EventsManager.comment_created(user: @user, comment: comment)
    NotificationManager.delay.notify_comment_created(comment)

    comment
  end

  # @param message [String]
  # @param mentions [Hash]
  # @return [Comment]
  def update(message: , mentions: nil)
    @comment.message = strip_tags(message)
    @comment.mentions = mentions if mentions
    save_or_die! @comment

    EventsManager.comment_updated(user: @user, comment: @comment)
    @comment
  end

  private

  # @param message [String]
  def strip_tags(message)
    Rails::Html::WhiteListSanitizer.new.sanitize(message, tags: []).strip
  end
end
