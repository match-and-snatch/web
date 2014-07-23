class UserManager < BaseManager
  attr_reader :user

  # @param user [User]
  def initialize(user)
    raise ArgumentError unless user.is_a?(User)
    @user = user
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
    save_or_die! @user
  end

  def remove_mark_billing_failed
    @user.billing_failed = false
    @user.billing_failed_at = nil
    save_or_die! @user
  end
end
