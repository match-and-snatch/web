class PhotosController < UploadsController
  before_filter :load_user!, only: [:profile_picture, :cover_picture]

  def profile_picture
    json_render
  end

  def cover_picture
    json_render
  end

  def create
    manager.create_pending_photo(params[:transloadit])
    json_replace html: render_to_string(partial: 'photo_posts/pending_uploads')
  end

  def destroy
    super
    json_render html: render_to_string(partial: 'photo_posts/pending_uploads')
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end