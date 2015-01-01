class SubscriptionsTag < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :tag
end