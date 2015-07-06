class Api::VideosController < Api::UploadsController
  def create
    video = manager.create_pending_video(params[:transloadit])
    json_success video_data(video)
  end

  private

  def video_data(video)
    {
      preview_url: current_user.pending_video_previews.first.try(:url),
      video: api_response.pending_video_data(video)
    }
  end
end
