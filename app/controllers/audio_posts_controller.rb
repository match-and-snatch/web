class AudioPostsController < MediaPostsController

  def cancel
    PostManager.new(user: current_user.object).cancel_pending_audios
    json_render html: render_to_string('new', layout: false)
  end

  protected

  def create_post
    PostManager.new(user: current_user.object).create_audio_post title:         params[:title],
                                                                 keywords_text: params[:keywords_text],
                                                                 message:       params[:message],
                                                                 notify:        params[:notify]
  end

  def cancel_media_posts_path
    cancel_audio_posts_path
  end

  def media_posts_path
    audio_posts_path
  end
  helper_method :media_posts_path, :cancel_media_posts_path
end
