class Video < Upload

  def to_m3u8
    if high_quality_playlist_url
      hq_playlist = <<-HQ_PLAYLIST
#EXT-X-STREAM-INF:PROGRAM-ID=1,NAME=High,BANDWIDTH=1677946,RESOLUTION=1920x1080
#{high_quality_playlist_url.sub('https:', 'http:')}
      HQ_PLAYLIST
    end

    if low_quality_playlist_url
      lq_playlist = <<-LQ_PLAYLIST
#EXT-X-STREAM-INF:PROGRAM-ID=1,NAME=Low,BANDWIDTH=707099,RESOLUTION=1280x720
#{low_quality_playlist_url.sub('https:', 'http:')}
      LQ_PLAYLIST
    end

    <<-PLAYLIST
#EXTM3U
#EXT-X-VERSION:3
#{hq_playlist}#{lq_playlist}
    PLAYLIST
  end
end
