class Subscription < ActiveRecord::Base
  include Concerns::Payable

  belongs_to :user
  belongs_to :target, polymorphic: true
  belongs_to :target_user, class_name: 'User'
  has_many :payments, as: :target

  validates :user, :target, :target_user, presence: true

  scope :by_target, -> (target) { where(target_type: target.class.name, target_id: target.id) }
  scope :not_removed, -> { where(removed: false) }

  # Returns upcoming billing date
  # @return [Date]
  def billing_date
    (charged_at || created_at).next_month.to_date
  end

  # @return [Integer] Amount in cents
  def cost
    (target_user.subscription_cost * 100).to_i
  end

  # @return [User]
  def customer
    user
  end

  def expired?
    removed? && billing_date < Time.zone.today
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
end
