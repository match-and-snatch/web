class VideosController < UploadsController

  def playlist
    if @upload.high_quality_playlist_url
      hq_playlist = <<-HQ_PLAYLIST
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1677946,RESOLUTION=1920x1080
#{@upload.high_quality_playlist_url.sub('https:', 'http:')}
HQ_PLAYLIST
    end

    if @upload.low_quality_playlist_url
      lq_playlist = <<-LQ_PLAYLIST
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=707099,RESOLUTION=1280x720
#{@upload.low_quality_playlist_url.sub('https:', 'http:')}
LQ_PLAYLIST
    end

    playlist =<<-PLAYLIST
#EXTM3U
#EXT-X-VERSION:3
#{hq_playlist}#{lq_playlist}
PLAYLIST

    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Accept-Ranges'] = 'bytes'

    render text: playlist, content_type: 'audio/x-mpegurl'
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