class MediaPostsController < PendingPostsController

  protected

  def media_posts_path
    raise NotImplementedError
  end
  helper_method :media_posts_path
end