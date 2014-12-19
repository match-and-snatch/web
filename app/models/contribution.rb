class Contribution < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :parent, class_name: 'Contribution'

  has_many :children, class_name: 'Contribution', foreign_key: 'parent_id'

  validates :amount, presence: true

  # @return [Date]
  def next_billing_date
    raise ArgumentError unless recurring?
    (children.maximum(:created_at) || created_at).next_month.to_date
  end
end
