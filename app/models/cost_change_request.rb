class CostChangeRequest < ActiveRecord::Base
  belongs_to :user

  scope :active, -> { where(approved: false, rejected: false) }

  def reject!
    self.rejected = true
    self.rejected_at = Time.zone.now
    self.save!
  end
end
