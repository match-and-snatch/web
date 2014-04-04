class VideosController < UploadsController

  def create
    manager.create_pending_video(params[:transloadit])
    json_replace
  end

  protected

  def json_replace(*args)
    super html: render_to_string(partial: 'pending_post_upload',
                                 collection: current_user.pending_post_uploads(true))
  end
end