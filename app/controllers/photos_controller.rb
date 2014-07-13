class PhotosController < UploadsController
  before_filter :load_user!, only: [:profile_picture, :cover_picture]
  skip_before_filter :authenticate!, only: [:profile_picture, :cover_picture]

  def show
    @photo = Photo.find(params[:id])
    @post = @photo.uploadable
    photos = @post.uploads.ordered.to_a
    if photos.count > 1
      index = photos.index(@photo)
      @prev_photo = photos[index - 1]

      if index == photos.count - 1
        @next_photo = photos[0]
      else
        @next_photo = photos[index + 1]
      end
    end
    json_render
  end

  def profile_picture
    json_render
  end

  def cover_picture
    json_render
  end

  def create
    manager.create_pending_photos(params[:transloadit])
    json_replace template: 'photo_posts/pending_uploads'
  end

  def destroy
    super
    json_render template: 'photo_posts/pending_uploads'
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end