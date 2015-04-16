class Api::AudioPostsController < Api::MediaPostsController
  def new
    json_success pending_audio_post_data
  end

  def cancel
    manager.cancel_pending_audios
    json_success
  end

  protected

  def create_post
    manager.create_audio_post(params.slice(%i(title keyword_text message)).merge({ notify: params.bool(:notify) }))
  end

  def pending_audio_post_data
    audio_post_data = {
      post_type: 'AudioPost',
      audios: current_user.pending_audios.map { |audio| audio_data(audio) }
    }
    pending_post_data.merge(audio_post_data)
  end

  def audio_data(audio)
    {
      id: audio.id,
      filename: audio.filename
    }
  end
end
