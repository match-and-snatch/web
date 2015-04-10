class Api::PhotoPostsController < Api::MediaPostsController
  def new
    json_success pending_photos_post_data
  end
  
  def cancel
    manager.cancel_pending_photos
    json_success
  end

  protected

  def create_post
    manager.create_photo_post(params.slice(%i(title keyword_text message)).merge({ notify: params.bool(:notify) }))
  end

  def pending_photos_post_data
    photos_post_data = {
      post_type: 'PhotosPost',
      photos: current_user.pending_photos.map { |photo| photo_data(photo) }
    }
    pending_post_data.merge(photos_post_data)
  end

  def photo_data(photo)
    {
      id: photo.id
    }
  end
end
