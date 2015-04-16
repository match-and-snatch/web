class Api::PhotosController < Api::UploadsController
  def create
    photos = manager.create_pending_photos(params[:transloadit])
    json_success photos_data(photos)
  end

  private

  def photos_data(photos)
    { photos: photos.map { |photo| photo_data(photo) } }
  end

  def photo_data(photo)
    {
      id: photo.id,
      preview_url: photo.preview_url
    }
  end
end
