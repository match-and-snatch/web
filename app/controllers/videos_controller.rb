class VideosController < UploadsController
  def create
    manager.create_pending_video(params[:transloadit])
    json_replace
  end
end