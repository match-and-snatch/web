class PhotoPostsController < PendingPostsController

  def cancel
    PostManager.new(user: current_user.object).cancel_pending_photos
    json_render html: render_to_string('new', layout: false)
  end

  protected

  def create_post
    PostManager.new(user: current_user.object).create_photo_post(params.slice(%i(title keyword_text message notify)))
  end

  def cancel_media_posts_path
    cancel_photo_posts_path
  end

  def media_posts_path
    photo_posts_path
  end
  helper_method :media_posts_path, :cancel_media_posts_path
end
