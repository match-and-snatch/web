class VideoPostsController < MediaPostsController

  def cancel
    PostManager.new(user: current_user.object).cancel_pending_videos
    json_render template: 'new'
  end

  protected

  def create_post
    PostManager.new(user: current_user.object).create_video_post(params.slice(%i(title keyword_text message preview_url)).merge({ notify: params.bool(:notify) }))
  end

  def cancel_media_posts_path
    cancel_video_posts_path
  end

  def media_posts_path
    video_posts_path
  end
  helper_method :media_posts_path, :cancel_media_posts_path
end