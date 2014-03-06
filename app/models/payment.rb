class Payment < ActiveRecord::Base
  serialize :stripe_charge_data, Hash

  belongs_to :target, polymorphic: true
  belongs_to :user
end
