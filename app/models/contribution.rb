class Contribution < ActiveRecord::Base
  belongs_to :user
  belongs_to :target_user, class_name: 'User'
  belongs_to :parent, class_name: 'Contribution'

  has_many :children, class_name: 'Contribution', foreign_key: 'parent_id'
  has_one :message, inverse_of: :contribution

  validates :amount, presence: true

  scope :recurring, -> { where(recurring: true) }
  scope :to_charge, -> { recurring
    .joins("INNER JOIN users ON users.id = contributions.target_user_id AND users.has_complete_profile = 't'")
    .where('contributions.updated_at <= ?', 1.month.ago) }
  scope :for_year, -> (year = Time.zone.now.year) { where(created_at: Time.new(year).beginning_of_year..Time.new(year).end_of_year) }

  def self.each_year_month(&block)
    self.reorder('contributions.created_at DESC').to_a.group_by(&:year_month).each(&block)
  end

  def self.total_amount
    sum(:amount)
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

  def recurring_performable?
    recurring? &&
      (next_billing_date <= Time.zone.now.to_date) &&
        user && target_user &&
          (!user.locked?) &&
            target_user.contributions_allowed?
  end
end
