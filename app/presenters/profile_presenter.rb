class ProfilePresenter
  delegate :email, :slug, to: :@user

  # @param user [User]
  def initialize(user)
    @user = user
  end

  def subscriptions
    []
  end
end