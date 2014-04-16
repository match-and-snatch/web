class AudioPostsController < MediaPostsController

  protected

  def create_post
    PostManager.new(user: current_user.object).create_audio_post title:         params[:title],
                                                                 keywords_text: params[:keywords_text],
                                                                 message:       params[:message]
  end

  def media_posts_path
    audio_posts_path
  end
  helper_method :media_posts_path
end
