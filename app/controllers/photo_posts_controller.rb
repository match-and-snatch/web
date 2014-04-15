class PhotoPostsController < MediaPostsController
  def create
  end

  protected

  def media_posts_path
    photo_posts_path
  end
  helper_method :media_posts_path
end
