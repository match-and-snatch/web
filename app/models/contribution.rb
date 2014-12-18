class Contribution < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :parent, class_name: 'Contribution'

  validates :amount, presence: true
end
