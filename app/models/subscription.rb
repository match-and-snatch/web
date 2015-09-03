class Subscription < ActiveRecord::Base
  include Concerns::Payable

  belongs_to :user
  belongs_to :target, polymorphic: true
  belongs_to :target_user, class_name: 'User'
  has_many :payments, as: :target
  has_many :payment_failures, as: :target

  validates :user, :target, :target_user, presence: true

  scope :by_target,    -> (target) { where(target_type: target.class.name, target_id: target.id) }
  scope :not_removed,  -> { where(removed: false) }
  scope :not_rejected, -> { where(rejected: false) }
  scope :been_charged, -> { where.not(charged_at: nil) }
  scope :to_charge,    -> { on_charge.not_removed.where(users: { vacation_enabled: false }) }
  scope :accessible,   -> { where("rejected_at is NULL OR rejected_at > ?", 1.month.ago) }
  scope :not_expired,  -> { where("COALESCE(subscriptions.charged_at, subscriptions.created_at) >= ?", 1.month.ago) }
  scope :active,       -> { not_removed.accessible }
  scope :visible,      -> { not_rejected.where(["subscriptions.removed = ? OR (subscriptions.removed = ? AND subscriptions.charged_at > ?)", false, true, 1.month.ago]) }

  # Returns upcoming billing date
  # @return [Date]
  def billing_date
    (charged_at || created_at).next_month.to_date
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

  def expired?
    billing_date < Time.zone.today
  end

  def paid?
    payments.any? && payments.maximum(:created_at).next_month.to_date >= Time.zone.today # billing_date > Time.zone.today
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
    day_of_payment_attempts >= 8
  end

  def notify_about_payment_failure?
    current_day = day_of_payment_attempts
    current_day.in?([0, 1, 3, 8]) || current_day > 8
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
