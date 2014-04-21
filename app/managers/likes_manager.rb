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
    else
      like = Like.create(user: @liker, likable: post, post: post, target_user: post.user)
      like.valid? or fail_with!(like.errors)
    end

    like
  end
end