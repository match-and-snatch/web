class VideoPostsController < MediaPostsController
  def create
    has_posts = current_user.has_posts?
    @post = PostManager.new(user: current_user.object).create_video_post title:         params[:title],
                                                                         keywords_text: params[:keywords_text],
                                                                         message:       params[:message]
    has_posts ? json_prepend : json_replace
  end

  protected

  def media_posts_path
    video_posts_path
  end
  helper_method :media_posts_path
end