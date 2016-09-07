class TosAcceptance < ActiveRecord::Base
  belongs_to :user
  belongs_to :tos_version
  belongs_to :performer, class_name: 'User'

  scope :active, -> { where(tos_version: TosVersion.active) }
end
