class VideosController < UploadsController

  def create
    manager.create_pending_video(params[:transloadit])
    json_replace html: pending_uploads_html
  end

  def destroy
    super
    json_render html: pending_uploads_html
  end

  private

  def pending_uploads_html
    render_to_string(partial: 'video_posts/pending_uploads')
  end
end