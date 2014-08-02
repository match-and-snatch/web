class SubscriptionsPresenter
  include Enumerable

  attr_reader :user

  # @param user [User]
  def initialize(user: )
    @user = user
  end

  def canceled
    @canceled_subscriptions ||= subscriptions.select { |s| s.expired? || s.rejected? }
  end

  def active
    @active_subscriptions ||= subscriptions.select { |s| !(s.expired? || s.rejected?) }
  end

  def show_failed_column?
    @canceled_subscriptions.select(&:rejected).any?
  end

  private

  def subscriptions
    user.subscriptions.all
  end
end
