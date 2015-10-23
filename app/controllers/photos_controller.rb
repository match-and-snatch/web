class PhotosController < UploadsController
  before_action :load_photo!, only: [:show]
  before_action :load_user!, only: [:profile_picture, :cover_picture]
  skip_before_action :authenticate!, only: [:profile_picture, :cover_picture]

  def show
    @post = @photo.uploadable
    photos = if @post
               @post.uploads
             else
               Photo.where(uploadable_id: @photo.uploadable_id,
                           uploadable_type: @photo.uploadable_type)
             end
    photos = photos.ordered.to_a
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
    json_replace partial: 'photo_posts/pending_uploads'
  end

  def destroy
    super
    json_render partial: 'photo_posts/pending_uploads'
  end

  private

  def load_photo!
    @photo = Photo.where(id: params[:id]).first or error(404)
  end

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end
