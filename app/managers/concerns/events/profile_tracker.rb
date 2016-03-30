module Concerns::Events::ProfileTracker
  # @param user [User]
  # @param data [Hash]
  # @yield
  # @return [Event]
  def profile_created(user: , data: {}, &block)
    Event.create! user: user, subject: user, action: 'profile_created', data: data, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def profile_page_removed(user: , &block)
    Event.create! user: user, subject: user, action: 'profile_page_removed', &block
  end

  # @param user [User]
  # @param picture [Photo]
  # @yield
  # @return [Event]
  def profile_picture_changed(user: , picture: , &block)
    Event.create! user: user,
                  subject: user,
                  action: 'profile_picture_changed',
                  data: { photo_id:    picture.id,
                          target_id:   picture.uploadable_id,
                          target_type: picture.uploadable_type,
                          url:         picture.url },
                  &block
  end

  # @param user [User]
  # @param picture [Photo]
  # @yield
  # @return [Event]
  def cover_picture_changed(user: , picture: , &block)
    Event.create! user: user,
                  subject: user,
                  action: 'cover_picture_changed',
                  data: { photo_id:    picture.id,
                          target_id:   picture.uploadable_id,
                          target_type: picture.uploadable_type,
                          url:         picture.url },
                  &block
  end

  # @param user [User]
  # @param name [String]
  # @yield
  # @return [Event]
  def profile_name_changed(user: , name: nil, &block)
    Event.create! user: user, subject: user, action: 'profile_name_changed', data: { name: name }, &block
  end

  # @param user [User]
  # @param from [Integer]
  # @param to [Integer]
  # @yield
  # @return [Event]
  def subscription_cost_changed(user: , from: , to: , &block)
    Event.create! user: user, subject: user, action: 'subscription_cost_changed', data: { from: from, to: to }, &block
  end

  # @param user [User]
  # @param benefits [Array]
  # @yield
  # @return [Event]
  def benefits_list_updated(user: , benefits: [], &block)
    Event.create! user: user, subject: user, action: 'benefits_list_updated', data: { new_benefits: benefits }, &block
  end

  # @param user [User]
  # @param media [Audio, Video]
  # @yield
  # @return [Event]
  def welcome_media_added(user: , media: , &block)
    Event.create! user: user,
                  subject: user,
                  action: 'welcome_media_added',
                  data: { photo_id:    media.id,
                          target_id:   media.uploadable_id,
                          target_type: media.uploadable_type,
                          url:         media.url,
                          type:        media.type },
                  &block
  end

  # @param user [User]
  # @param info [Hash]
  # @yield
  # @return [Event]
  def contact_info_changed(user: , info: {}, &block)
    Event.create! user: user, subject: user, action: 'contact_info_changed', data: info, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def welcome_media_removed(user: , &block)
    Event.create! user: user, subject: user, action: 'welcome_media_removed', &block
  end
end
