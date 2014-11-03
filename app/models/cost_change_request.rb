class CostChangeRequest < ActiveRecord::Base
  belongs_to :user

  scope :pending,   -> { where(approved: false, rejected: false, performed: false) }
  scope :approved,  -> { where(approved: true,  rejected: false, performed: false) }
end
