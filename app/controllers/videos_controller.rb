class VideosController < UploadsController

  def create
    manager.create_pending_video(params[:transloadit])
    json_replace partial: 'video_posts/pending_uploads'
  end

  def destroy
    super
    json_render partial: 'video_posts/pending_uploads'
  end
end