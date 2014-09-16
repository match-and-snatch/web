class LikesManager < BaseManager

  # @param liker [User]
  def initialize(liker)
    @liker = liker
  end

  # @param post [Post]
  # @return [Like]
  def toggle(post)
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