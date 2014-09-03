class UserProfileEventManager < BaseManager

  attr_reader :user

  # @params user [User]
  def initialize(user: nil)
    @user = user
  end

  def track_change_cost(from: , to: )
    data = { from: from, to: to }
    UserProfileEvent.create! user: user, message: 'User changed cost', data: data
  end
end