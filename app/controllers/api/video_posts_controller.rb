class Api::VideoPostsController < Api::MediaPostsController
  def new
    json_success pending_video_post_data(current_user.pending_videos.last)
  end

  def cancel
    manager.cancel_pending_videos
    json_success
  end

  protected

  def create_post
    manager.create_video_post params.slice(:title, :keyword_text, :message, :preview_url).merge(notify: params.bool(:notify))
  end

  def pending_video_post_data(video)
    custom_preview = if current_user.pending_video_previews.count > 2
                       current_user.pending_video_previews.last
                     end
    video_post_data = {
      post_type: 'VideoPost',
      preview_url: (custom_preview ? custom_preview.url : current_user.pending_video_previews.first.try(:url)),
      video: api_response.pending_video_data(video).tap do |data|
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
end
