class Api::VideoPostsController < Api::MediaPostsController
  def new
    json_success pending_video_post_data
  end

  def cancel
    manager.cancel_pending_videos
    json_success
  end

  protected

  def create_post
    manager.create_video_post params.slice(:title, :keyword_text, :message, :preview_url).merge(notify: params.bool(:notify))
  end

  def pending_video_post_data
    custom_preview = current_user.pending_video_previews.last if current_user.pending_video_previews.count > 2
    video_post_data = {
      post_type: 'VideoPost',
      preview_url: (custom_preview ? custom_preview.url : current_user.pending_video_previews.first.try(:url)),
      video: video_data.tap do |data|
        if custom_preview
          data[:custom_preview] = {
            id: custom_preview.id,
            url: custom_preview.url
          }
        end
      end
    }
    pending_post_data.merge(video_post_data)
  end

  def video_data
    {
      id: current_user.pending_videos.last.try(:id),
      previews: current_user.object.pending_video_preview_photos(true).first(2).map do |preview|
        {
          id: preview.id,
          url: preview.url
        }
      end
    }
  end
end
