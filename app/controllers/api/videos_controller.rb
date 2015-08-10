class Api::VideosController < Api::UploadsController
  def create
    video = manager.create_pending_video(params[:transloadit])
    json_success video_data(video)
  end

  private

  def video_data(video)
    {
      preview_url: current_user.object.pending_video_preview_photos(true).first.try(:url),
      video: api_response.pending_video_data(video)
    }
  end
end
