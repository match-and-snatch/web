class VideosController < UploadsController

  def playlist
    playlist =<<-PLAYLIST
#EXTM3U
#EXT-X-VERSION:3
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=1677946,RESOLUTION=1920x1080
http://buddy-video-assets.s3.amazonaws.com/8489c040b69511e4aee09f1afec3c8eb___high_playlist____high_playlist.m3u8
#EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=707099,RESOLUTION=1280x720
http://buddy-video-assets.s3.amazonaws.com/8489c040b69511e4aee09f1afec3c8eb___low_playlist____low_playlist.m3u8
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