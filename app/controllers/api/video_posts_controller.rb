class Api::VideoPostsController < Api::MediaPostsController
  def new
    json_success pending_video_post_data
  end

  def cancel
    PostManager.new(user: current_user.object).cancel_pending_videos
    json_success
  end

  protected

  def create_post
    PostManager.new(user: current_user.object).create_video_post(params.slice(%i(title keyword_text message)).merge({ notify: params.bool(:notify) }))
  end

  def pending_video_post_data
    video_post_data = {
      post_type: 'VideoPost',
      video: {
        id: current_user.pending_videos.last.try(:id),
        preview_url: current_user.pending_videos.last.try(:preview_url)
      }
    }
    pending_post_data.merge(video_post_data)
  end
end
