class AudioPostsController < MediaPostsController

  def cancel
    PostManager.new(user: current_user.object).cancel_pending_audios
    json_render template: 'new'
  end

  protected

  def create_post
    PostManager.new(user: current_user.object).create_audio_post(params.slice(%i(title keyword_text message notify)))
  end

  def cancel_media_posts_path
    cancel_audio_posts_path
  end

  def media_posts_path
    audio_posts_path
  end
  helper_method :media_posts_path, :cancel_media_posts_path
end
