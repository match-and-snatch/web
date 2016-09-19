module Concerns::Events::AccountTracker

  # @param user [User]
  # @param reason [String]
  # @yield
  # @return [Event]
  def account_locked(user: , type: , reason: , &block)
    create_event user: user,
                  subject: user,
                  action: 'account_locked',
                  data: {type: type, reason: reason},
                  &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def account_unlocked(user: ,&block)
    create_event user: user,
                  subject: user,
                  action: 'account_unlocked',
                  data: {},
                  &block
  end

  # @param user [User]
  # @param photo [Photo]
  # @yield
  # @return [Event]
  def account_photo_changed(user: , photo: , &block)
    create_event user: user,
                  subject: user,
                  action: 'account_photo_changed',
                  data: {photo_id:    photo.id,
                         target_id:   photo.uploadable_id,
                         target_type: photo.uploadable_type,
                         url:         photo.url},
                  &block
  end

  # @param user [User]
  # @param data [Hash]
  # @yield
  # @return [Event]
  def account_information_changed(user: , data: {}, &block)
    create_event user: user, subject: user, action: 'account_information_changed', data: data, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def password_changed(user: , &block)
    create_event user: user, subject: user, action: 'password_changed', &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def payout_information_changed(user: , &block)
    create_event user: user, subject: user, action: 'payout_information_changed', &block
  end

  # @param user [User]
  # @param slug [String]
  # @yield
  # @return [Event]
  def slug_changed(user: , slug: nil, &block)
    create_event user: user, subject: user, action: 'slug_changed', data: {slug: slug}, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def credit_card_updated(user: , &block)
    create_event user: user, subject: user, action: 'credit_card_updated', &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def credit_card_declined(user: , data: , &block)
    create_event user: user, subject: user, action: 'credit_card_declined', data: data, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def credit_card_restored(user: , data: , &block)
    create_event user: user, subject: user, action: 'credit_card_restored', data: data, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def credit_card_removed(user: , data: , &block)
    create_event user: user, subject: user, action: 'credit_card_removed', data: data, &block
  end

  # @param user [User]
  # @param reason [String]
  # @yield
  # @return [Event]
  def vacation_mode_enabled(user: , reason: nil, &block)
    create_event user: user,
                  subject: user,
                  action: 'vacation_mode_enabled', data: {reason: reason,
                                                          subscribers_count: user.subscribers_count}, &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def vacation_mode_disabled(user: , affected_users_count: 0, &block)
    create_event user: user,
                  subject: user,
                  action: 'vacation_mode_disabled', data: {affected_users_count: affected_users_count,
                                                           subscribers_count: user.subscribers_count}, &block
  end

  # @param user [User]
  # @return [Event]
  def tos_accepted(user: , &block)
    create_event user: user, subject: user, action: 'tos_accepted', &block
  end

  # @param user [User]
  # @param from [Integer]
  # @param to [Integer]
  # @yield
  # @return [Event]
  def subscriptions_limit_changed(user: , from: , to: , &block)
    create_event user: user, subject: user, action: 'subscriptions_limit_changed', data: {from: from, to: to}, &block
  end
end
