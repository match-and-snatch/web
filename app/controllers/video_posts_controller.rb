class VideoPostsController < MediaPostsController

  def cancel
    PostManager.new(user: current_user.object).cancel_pending_videos
    json_render html: render_to_string('new', layout: false)
  end

  protected

  def create_post
    PostManager.new(user: current_user.object).create_video_post(params.slice(:title, :keyword_text, :message, :notify))
  end

  def cancel_media_posts_path
    cancel_video_posts_path
  end

  def media_posts_path
    video_posts_path
  end
  helper_method :media_posts_path, :cancel_media_posts_path
end