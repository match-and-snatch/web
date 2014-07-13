class AudiosController < UploadsController

  def create
    manager.create_pending_audios(params[:transloadit])
    json_replace partial: 'audio_posts/pending_uploads'
  end

  def destroy
    super
    json_render partial: 'audio_posts/pending_uploads'
  end

  def reorder
    manager.reorder(params[:ids])
    json_success
  end
end