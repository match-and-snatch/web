class PhotosController < UploadsController

  def show
    json_render
  end

  def create
    manager.create_pending_photo(params[:transloadit])
    json_replace html: render_to_string(partial: 'pending_post_upload',
                                        collection: current_user.pending_post_uploads(true))
  end

  def destroy
    super
    json_render html: render_to_string(partial: 'pending_post_upload',
                                       collection: current_user.pending_post_uploads(true))
  end
end