module Concerns::Events::SessionTracker
  # @param user [User]
  # @yield
  # @return [Event]
  def user_logged_in(user: , &block)
    Event.create! user: user, action: 'logged_in', &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def user_registered(user: , &block)
    Event.create! user: user, action: 'registered', &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def restore_password_requested(user: , &block)
    Event.create! user: user, action: 'restore_password_requested', &block
  end

  # @param user [User]
  # @yield
  # @return [Event]
  def password_restored(user: , &block)
    Event.create! user: user, action: 'password_restored', &block
  end
end
