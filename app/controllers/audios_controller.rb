class AudiosController < UploadsController

  def create
    manager.create_pending_audios(params[:transloadit])
    json_replace html: render_to_string(partial: 'audio_posts/pending_uploads')
  end

  def destroy
    super
    json_render html: render_to_string(partial: 'audio_posts/pending_uploads')
  end
end