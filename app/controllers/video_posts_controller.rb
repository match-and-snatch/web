class VideoPostsController < MediaPostsController

  def cancel
    PostManager.new(user: current_user.object).cancel_pending_videos
    json_render html: render_to_string('new', layout: false)
  end

  protected

  def create_post
    PostManager.new(user: current_user.object).create_video_post title:         params[:title],
                                                                 keywords_text: params[:keywords_text],
                                                                 notify:        params[:notify],
                                                                 message:       params[:message]
  end

  def cancel_media_posts_path
    cancel_video_posts_path
  end

  def media_posts_path
    video_posts_path
  end
  helper_method :media_posts_path, :cancel_media_posts_path
end