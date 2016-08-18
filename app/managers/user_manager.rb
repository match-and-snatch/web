class UserManager < BaseManager
  attr_reader :user, :performer

  LOCK_TYPES = %w(account billing tos).freeze
  LOCK_REASONS = %w(manually_set fraudulent contribution_limit subscription_limit cc_update_limit cc_used_by_another_account).freeze

  # @param user [User]
  def initialize(user, performer = user)
    raise ArgumentError unless user.is_a?(User)
    raise ArgumentError unless performer.is_a?(User)
    @user = user
    @performer = performer
  end

  # Activates user if needed
  def activate
    unless user.activated?
      user.activated = true
      user.save!
    end
  end

  User::ROLE_FIELDS.each do |field, role|
    role_name = role.parameterize(separator: '_')

    define_method "make_#{role_name}" do
      fail_with! "User is already #{role.humanize}" if @user.public_send("#{role_name}?")

      @user.public_send(:"#{field}=", true)
      save_or_die! @user
    end
  end

  User::ROLE_FIELDS.each do |field, role|
    role_name = role.parameterize(separator: '_')

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

  # @param type [String, Symbol] account, billing or tos
  # @yield
  def lock(type: :account, reason: :manually_set)
    return if @user.is_admin?

    fail_with! 'No valid type provided' unless LOCK_TYPES.include?(type.to_s)
    fail_with! 'No valid reason provided' unless LOCK_REASONS.include?(reason.to_s)

    @user.lock!(type: type, reason: reason).tap do
      EventsManager.account_locked(user: @user, type: type.to_s, reason: reason.to_s)
      yield @user if block_given?
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

  def update_adult_subscriptions_limit(limit)
    old_limit = @user.adult_subscriptions_limit

    fail_with! adult_subscriptions_limit: :empty if limit.blank?
    fail_with! adult_subscriptions_limit: :zero  if limit.to_i < 1
    fail_with! adult_subscriptions_limit: 'Please, enter new value' if limit.to_i == old_limit

    @user.adult_subscriptions_limit = limit.to_i
    @user.adult_subscriptions_limit_changed_at = Time.zone.now
    save_or_die! @user

    EventsManager.subscriptions_limit_changed(user: @user, from: old_limit, to: limit.to_i)
  end

  def log_recent_subscriptions_count(recent_subscriptions_count)
    @user.recent_subscriptions_count = recent_subscriptions_count
    @user.recent_subscription_at = Time.zone.now
    save_or_die! @user
  end

  # @param accepted [Boolean]
  def mark_tos_accepted(accepted: false)
    fail_with! tos_accepted: :not_accepted unless accepted

    @user.tos_accepted = accepted
    save_or_die! @user
    @user.tos_acceptances.create!(tos_version: TosVersion.active,
                                  user_email: @user.email,
                                  user_full_name: @user.full_name,
                                  performer_id: performer.id,
                                  performed_by_admin: performer.admin?)
    EventsManager.tos_accepted(user: @user)
  end

  def toggle_tos_acceptance
    @user.tos_accepted = !@user.tos_accepted?
    save_or_die! @user
    if @user.tos_accepted?
      ActiveRecord::Base.transaction do
        @user.tos_acceptances.create!(tos_version: TosVersion.active,
                                      user_email: @user.email,
                                      user_full_name: @user.full_name,
                                      performer_id: performer.id,
                                      performed_by_admin: performer.admin?)
      end
    else
      @user.tos_acceptances.active.destroy_all
    end
  end

  # @return [User]
  def set_invalid_email
    user.email = "#{user.email}___xxx"
    save_or_die! user
    user.elastic_index_document
    user
  end
end
