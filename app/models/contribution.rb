class Contribution < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :parent, class_name: 'Contribution'

  has_many :children, class_name: 'Contribution', foreign_key: 'parent_id'

  validates :amount, presence: true

  def self.each_year_month(&block)
    self.reorder('contributions.created_at DESC').to_a.group_by(&:year_month).each(&block)
  end

  # @return [Date]
  def next_billing_date
    raise ArgumentError unless recurring?
    (children.maximum(:created_at) || created_at).next_month.to_date
  end

  def will_repeat?
    !!(recurring? || parent_id)
  end

  def year_month
    @year_month ||= YearMonth.new(created_at.year, created_at.month)
  end
end
