class Api::PendingVideoPreviewsController < Api::UploadsController

  def create
    previews = manager.create_pending_video_previews(params[:transloadit])
    json_success({ id: previews.first.id, url: previews.first.url })
  end
end
