class Api::VideosController < Api::UploadsController
  def create
    video = manager.create_pending_video(params[:transloadit])
    json_success video_data(video)
  end

  private

  def video_data(video)
    {
      video: {
        id: video.id,
        preview_url: video.preview_url
      }
    }
  end
end
