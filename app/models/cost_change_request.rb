class CostChangeRequest < ActiveRecord::Base
  belongs_to :user

  scope :pending,   -> { where(approved: false, rejected: false, performed: false) }
  scope :approved,  -> { where(approved: true,  rejected: false, performed: false) }

  def reject!
    self.rejected = true
    self.rejected_at = Time.zone.now
    self.save!
  end

  def approve!(update_existing_costs: nil)
    unless update_existing_costs.nil?
      self.update_existing_subscriptions = update_existing_costs
    end

    self.approved = true
    self.approved_at = Time.zone.now
    self.save!
  end

  def perform!
    self.performed = true
    self.performed_at = Time.zone.now
    self.save!
  end
end
