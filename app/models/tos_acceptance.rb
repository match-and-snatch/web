class TosAcceptance < ActiveRecord::Base
  belongs_to :user
  belongs_to :tos_version

  scope :active, -> { where(tos_version: TosVersion.active) }
end
