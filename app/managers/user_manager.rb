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

  def make_admin
    fail_with! 'User is already admin' if @user.admin?

    @user.is_admin = true
    @user.save or fail_with!(@user.errors)

    @user
  end

  def drop_admin
    fail_with! 'User is not an admin' unless @user.admin?

    @user.is_admin = false
    save_or_die! @user

    @user
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

  def save_last_visited_profile(target_user)
    if @user.subscribed_to?(target_user) && @user.last_visited_profile_id != target_user.id
      @user.last_visited_profile_id = target_user.id
      save_or_die! @user
    end
  end
end
