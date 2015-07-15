class Api::AudiosController < Api::UploadsController
  protect(:reorder) { current_user.authorized? } # TODO (DJ): FIX IT

  def create
    audios = manager.create_pending_audios(params[:transloadit])
    json_success audios_data(audios)
  end

  def reorder
    manager.reorder(params[:ids])
    json_success audios_data(current_user.pending_audios)
  end

  private

  def audios_data(audios)
    { audios: api_response.audios_data(audios) }
  end
end
