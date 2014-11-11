class CostChangeRequest < ActiveRecord::Base
  belongs_to :user

  scope :pending,   -> { where(approved: false, rejected: false, performed: false) }
  scope :approved,  -> { where(approved: true,  rejected: false, performed: false) }

  def reject!
    self.rejected = true
    self.rejected_at = Time.zone.now
    self.save!
  end

  def approve!
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
