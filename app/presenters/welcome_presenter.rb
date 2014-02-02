class WelcomePresenter

  def initialize(user)
    @user = user
  end

  def recommended_subscriptions
    Subscription.where.not(user_id: @user.id).limit(10).order('RANDOM()')
  end
end