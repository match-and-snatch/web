class SessionEventManager < BaseManager

  attr_reader :user

  # @params user [User]
  def initialize(user: nil)
    @user = user
  end

  def track_login
    SessionEvent.create! user: user, message: 'User successfully logged in'
  end

  def track_logout
    SessionEvent.create! user: user, message: 'User successfully logged out'
  end

  def track_registration
    SessionEvent.create! user: user, message: 'User successfully registered'
  end
end