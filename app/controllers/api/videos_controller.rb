class Api::VideosController < Api::UploadsController
  def create
    video = manager.create_pending_video(params[:transloadit])
    json_success video_data(video)
  end

  private

  def video_data(video)
    {
      preview_url: current_user.pending_video_previews.first.try(:url),
      video: {
        id: video.id,
        preview_url: video.preview_url,
        previews: current_user.pending_video_previews.map do |preview|
          {
            id: preview.id,
            url: preview.url
          }
        end
      }
    }
  end
end
