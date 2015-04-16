class Api::AudiosController < Api::UploadsController
  protect(:reorder) { current_user.authorized? } # TODO (DJ): FIX IT

  def create
    audios = manager.create_pending_audios(params[:transloadit])
    json_success audios_data(audios)
  end

  def reorder
    manager.reorder(params[:ids])
    json_success
  end

  private

  def audios_data(audios)
    { audios: audios.map { |audio| audio_data(audio) } }
  end

  def audio_data(audio)
    {
      id: audio.id,
      filename: audio.filename
    }
  end
end
