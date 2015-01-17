class LikesManager < BaseManager

  # @param liker [User]
  def initialize(liker)
    @liker = liker
  end

  # @param post [Post, Comment]
  # @return [Like]
  def toggle(likable)
    case likable
    when Post
      toggle_post(likable)
    when Comment
      toggle_comment(likable)
    else
      raise ArgumentError
    end
  end

  private

  def toggle_comment(comment)
    like = @liker.likes.where(comment_id: comment.id).first

    if like
      like.destroy
      EventsManager.like_removed(user: @liker, like: like)
    else
      like = Like.create(user: @liker, likable: comment, comment: comment, target_user: comment.user)
      save_or_die! like
      EventsManager.like_created(user: @liker, like: like)
    end

    like
  end

  def toggle_post(post)
    like = @liker.likes.where(post_id: post.id).first

    if like
      like.destroy
      EventsManager.like_removed(user: @liker, like: like)
    else
      like = Like.create(user: @liker, likable: post, post: post, target_user: post.user)
      save_or_die! like
      EventsManager.like_created(user: @liker, like: like)
    end

    like
  end
end
