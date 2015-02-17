class VideosController < UploadsController

  def playlist
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Accept-Ranges'] = 'bytes'

    render text: @upload.to_m3u8, content_type: 'audio/x-mpegurl'
  end

  def create
    manager.create_pending_video(params[:transloadit])
    json_replace partial: 'video_posts/pending_uploads'
  end

  def destroy
    super
    json_render partial: 'video_posts/pending_uploads'
  end
end