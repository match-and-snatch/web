class UserManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user)
    raise ArgumentError unless user.is_a?(User)
    @user = user
  end

  # Activates user if needed
  def activate
    unless user.activated?
      user.activated = true
      user.save!
    end
  end

  User::ROLE_FIELDS.each do |field, role|
    role_name = role.parameterize('_')

    define_method "make_#{role_name}" do
      fail_with! "User is already #{role.humanize}" if @user.public_send("#{role_name}?")

      @user.public_send(:"#{field}=", true)
      save_or_die! @user
    end
  end

  User::ROLE_FIELDS.each do |field, role|
    role_name = role.parameterize('_')

    define_method "drop_#{role_name}" do
      fail_with! "User is not #{role.humanize}" unless @user.public_send("#{role_name}?")

      @user.public_send(:"#{field}=", false)
      save_or_die! @user
    end
  end

  def mark_billing_failed
    @user.billing_failed = true
    @user.billing_failed_at = Time.zone.now
    save_or_die! @user do
      UserStatsManager.new(@user).log_subscriptions_count
    end
  end

  def remove_mark_billing_failed
    @user.billing_failed = false
    @user.billing_failed_at = nil
    save_or_die! @user do
      UserStatsManager.new(@user).log_subscriptions_count
    end
  end

  # @param reason [String, Symbol] account, billing or tos
  def lock(reason = :account)
    fail_with! 'No valid reason provided' unless %w(account billing tos).include?(reason.to_s)

    @user.lock!(reason).tap do
      EventsManager.account_locked(user: @user, reason: reason)
    end
  end

  def unlock
    @user.credit_card_update_requests.destroy_all
    @user.recent_subscriptions_count = 0
    @user.unlock!.tap do
      EventsManager.account_unlocked(user: @user)
    end
  end

  def save_last_visited_profile(target_user)
    if @user.subscribed_to?(target_user) && @user.last_visited_profile_id != target_user.id
      @user.last_visited_profile_id = target_user.id
      save_or_die! @user
    end
  end

  def update_daily_contributions_limit(limit: )
    @user.daily_contributions_limit = limit.to_i
    save_or_die! @user
  end

  def log_recent_subscriptions_count(recent_subscriptions_count)
    @user.recent_subscriptions_count = recent_subscriptions_count
    @user.recent_subscription_at = Time.zone.now
    save_or_die! @user
  end
end
