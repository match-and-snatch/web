module Concerns::Events::AccountTracker

  # @param user [User]
  # @param reason [String]
  # @yield
  # @return [Event]
  def account_locked(user: , type: , reason: , &block)
    Event.create! user: user,
                  action: 'account_locked',
                  data: { type: type, reason: reason },
                  &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def account_unlocked(user: ,&block)
    Event.create! user: user,
                  action: 'account_unlocked',
                  data: {},
                  &block
  end

  # @param user [User]
  # @param photo [Photo]
  # @yield
  # @return [Event]
  def account_photo_changed(user: , photo: , &block)
    Event.create! user: user,
                  action: 'account_photo_changed',
                  data: { photo_id:    photo.id,
                          target_id:   photo.uploadable_id,
                          target_type: photo.uploadable_type,
                          url:         photo.url },
                  &block
  end

  # @param user [User]
  # @param data [Hash]
  # @yield
  # @return [Event]
  def account_information_changed(user: , data: {}, &block)
    Event.create! user: user, action: 'account_information_changed', data: data, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def password_changed(user: , &block)
    Event.create! user: user, action: 'password_changed', &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def payout_information_changed(user: , &block)
    Event.create! user: user, action: 'payout_information_changed', &block
  end

  # @param user [User]
  # @param slug [String]
  # @yield
  # @return [Event]
  def slug_changed(user: , slug: nil, &block)
    Event.create! user: user, action: 'slug_changed', data: { slug: slug }, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def credit_card_updated(user: , &block)
    Event.create! user: user, action: 'credit_card_updated', &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def credit_card_declined(user: , data: , &block)
    Event.create! user: user, action: 'credit_card_declined', data: data, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def credit_card_restored(user: , data: , &block)
    Event.create! user: user, action: 'credit_card_restored', data: data, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def credit_card_removed(user: , data: , &block)
    Event.create! user: user, action: 'credit_card_removed', data: data, &block
  end

  # @param user [User]
  # @param reason [String]
  # @yield
  # @return [Event]
  def vacation_mode_enabled(user: , reason: nil, &block)
    Event.create! user: user, action: 'vacation_mode_enabled', data: { reason: reason }, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def vacation_mode_disabled(user: , affected_users_count: 0, &block)
    Event.create! user: user, action: 'vacation_mode_disabled', data: { affected_users_count: affected_users_count }, &block
  end
end
