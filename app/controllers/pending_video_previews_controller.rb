class PendingVideoPreviewsController < UploadsController

  def create
    manager.create_pending_video_previews(params[:transloadit])
    json_replace partial: 'pending_video_previews/preview'
  end

  def destroy
    super
    json_replace partial: 'pending_video_previews/preview'
  end
end
