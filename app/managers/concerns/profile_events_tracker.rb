module Concerns::ProfileEventsTracker
  # @param user [User]
  # @param data [Hash]
  def profile_created(user: , data: {})
    Event.create! user: user, action: 'profile_created', data: data
  end

  # @param user [User]
  def profile_page_removed(user: )
    Event.create! user: user, action: 'profile_page_removed'
  end

  # @param user [User]
  # @param picture [Photo]
  def profile_picture_changed(user: , picture: )
    Event.create! user: user, action: 'profile_picture_changed', data: { id: picture.id, type: picture.type }
  end

  # @param user [User]
  # @param picture [Photo]
  def cover_picture_changed(user: , picture: )
    Event.create! user: user, action: 'cover_picture_changed', data: { id: picture.id, type: picture.type }
  end

  # @param user [User]
  # @param name [String]
  def profile_name_changed(user: , name: nil)
    Event.create! user: user, action: 'profile_name_changed', data: { name: name }
  end

  # @param user [User]
  # @param from [Integer]
  # @param to [Integer]
  def subscription_cost_changed(user: , from: , to: )
    Event.create! user: user, action: 'cost_changed', data: { from: from, to: to }
  end

  # @param user [User]
  # @param benefits [Array]
  def benefits_list_updated(user: , benefits: [])
    Event.create! user: user, action: 'benefits_list_updated', data: { new_benefits: benefits }
  end

  # @param user [User]
  # @param media [Audio, Video]
  def welcome_media_added(user: , media: )
    Event.create! user: user, action: 'welcome_media_added', data: { id: media.id, type: media.type }
  end

  def contact_info_changed(user: , info: )
    Event.create! user: user, action: 'contact_info_changed', data: info
  end

  # @param user [User]
  def welcome_media_removed(user: )
    Event.create! user: user, action: 'welcome_media_removed'
  end
end