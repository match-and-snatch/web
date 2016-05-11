class Subscription < ActiveRecord::Base
  include Concerns::Payable

  belongs_to :user, counter_cache: true
  belongs_to :target, polymorphic: true
  belongs_to :target_user, class_name: 'User', counter_cache: :total_subscribers_count
  has_many :payments, as: :target
  has_many :payment_failures, as: :target

  validates :user, :target, :target_user, presence: true

  scope :by_target,    -> (target) { where(target_type: target.class.name, target_id: target.id) }
  scope :not_removed,  -> { where(removed: false) }
  scope :not_rejected, -> { where(rejected: false) }
  scope :been_charged, -> { where.not(charged_at: nil) }
  scope :to_charge,    -> { not_paid.joins(user: :payments) }
  scope :not_paid,     -> { on_charge.not_removed.where(fake: false, users: { vacation_enabled: false }) }
  scope :active,       -> { not_removed.where("rejected_at is NULL OR rejected_at > ?", 1.month.ago) }
  scope :accessible,   -> { not_rejected.joins(:target_user)
                              .where(users: {is_profile_owner: true})
                              .where(["subscriptions.removed = ? OR (subscriptions.removed = ? AND subscriptions.charged_at > ?)", false, true, 1.month.ago]) }

  # Returns upcoming billing date
  # @return [Date]
  def billing_date
    if processing_payment?
      Time.zone.today
    else
      return (created_at || Time.zone.now).to_date unless charged_at

      upcoming_billing_date = charged_at + Concerns::Payable::DEFAULT_BILLING_CYCLE_LENGTH

      # Handle February
      if upcoming_billing_date.month > charged_at.month + 1
        upcoming_billing_date = charged_at.next_month
      end

      upcoming_billing_date.to_date
    end
  end

  def actualize_cost!
    self.cost = target_user.cost
    self.fees = target_user.subscription_fees
    self.total_cost = target_user.subscription_cost
    self.save!
  end

  # @return [User]
  def customer
    user
  end

  # @return [Boolean]
  def payable?
    user && target_user && (!user.locked?) && target_user.profile_payable? && !paid?
  end

  def expired?
    billing_date < Time.zone.today
  end

  def paid?
    !!(charged_at && charged_at > billing_edge_date)
  end

  # @return [User]
  def recipient
    target_user
  end

  def remove!
    self.removed = true
    self.removed_at = Time.zone.now
    self.save!
  end

  def restore!
    self.removed = false
    self.removed_at = nil
    self.save!
  end

  def statement_description
    target_user.name
  end

  def payment_attempts_expired?
    day_of_payment_attempts >= 5
  end

  def notify_about_payment_failure?
    current_day = day_of_payment_attempts
    current_day.in?([0, 1, 3, 5]) || current_day > 5
  end

  # @return [DateTime]
  def canceled_at
    removed? ? removed_at : rejected_at
  end

  private

  # @return [Integer]
  def day_of_payment_attempts
    (Time.zone.today - (rejected_at.try(:to_date) || Time.zone.today)).to_i
  end
end
