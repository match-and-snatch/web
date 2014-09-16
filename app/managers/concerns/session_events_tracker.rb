module Concerns::SessionEventsTracker
  # @param user [User]
  # @return [Event]
  def user_logged_in(user: )
    Event.create! user: user, action: 'logged_in'
  end

  # @param user [User]
  # @return [Event]
  def user_registered(user: )
    Event.create! user: user, action: 'registered'
  end

  # @param user [User]
  # @return [Event]
  def restore_password_requested(user: )
    Event.create! user: user, action: 'restore_password_requested'
  end

  # @param user [User]
  # @return [Event]
  def password_restored(user: )
    Event.create! user: user, action: 'password_restored'
  end
end