class SubscriptionsPresenter
  include Enumerable

  attr_reader :user

  # @param user [User]
  def initialize(user: )
    @user = user
  end

  def canceled
    @canceled_subscriptions ||= subscriptions.select { |s| s.removed? || s.rejected? }
  end

  def active
    @active_subscriptions ||= subscriptions - canceled
  end

  def show_failed_column?
    canceled.select(&:rejected).any?
  end

  private

  def subscriptions
    user.subscriptions.joins(:target_user).all
  end
end
