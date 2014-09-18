module Concerns::Events::AccountTracker
  # @param user [User]
  # @param photo [Photo]
  def account_photo_changed(user: , photo: )
    Event.create! user: user,
                  action: 'account_photo_changed',
                  data: { photo_id:    photo.id,
                          target_id:   photo.uploadable_id,
                          target_type: photo.uploadable_type,
                          url:         photo.url }
  end

  # @param user [User]
  # @param data [Hash]
  def account_information_changed(user: , data: {})
    Event.create! user: user, action: 'account_information_changed', data: data
  end

  # @param user [User]
  def password_changed(user: )
    Event.create! user: user, action: 'password_changed'
  end

  # @param user [User]
  def payout_information_changed(user: )
    Event.create! user: user, action: 'payout_information_changed'
  end

  # @param user [User]
  # @param slug [String]
  def slug_changed(user: , slug: nil)
    Event.create! user: user, action: 'slug_changed', data: { slug: slug }
  end

  # @param user [User]
  def credit_card_updated(user: )
    Event.create! user: user, action: 'credit_card_updated'
  end

  # @param user [User]
  # @param reason [String]
  def vacation_mode_enabled(user: , reason: nil)
    Event.create! user: user, action: 'vacation_mode_enabled', data: { reason: reason }
  end

  # @param user [User]
  def vacation_mode_disabled(user: )
    Event.create! user: user, action: 'vacation_mode_disabled'
  end
end