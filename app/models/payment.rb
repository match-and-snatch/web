class Payment < ActiveRecord::Base
  serialize :stripe_charge_data, Hash

  belongs_to :target, polymorphic: true
  belongs_to :subscription, foreign_key: :target_id
  belongs_to :user
  belongs_to :target_user, class_name: 'User'

  has_many :refunds
end
