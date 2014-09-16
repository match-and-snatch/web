module Concerns::AccountEventsTracker
  # @param user [User]
  # @param photo [Photo]
  def account_photo_changed(user: , photo: )
    Event.create! user: user, action: 'account_photo_changed', data: { id: photo.id, type: photo.type }
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
  def vacation_mode_enabled(user: )
    Event.create! user: user, action: 'vacation_mode_enabled'
  end

  # @param user [User]
  def vacation_mode_disabled(user: )
    Event.create! user: user, action: 'vacation_mode_disabled'
  end
end