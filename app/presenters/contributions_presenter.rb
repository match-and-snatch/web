class ContributionsPresenter
  attr_reader :user, :year

  delegate :each_year_month, :total_amount, to: :contributions

  # @param user [User]
  # @param year [String, Integer]
  def initialize(user: , year: nil)
    raise ArgumentError unless user.is_a?(User)

    @user = user
    @year = year || current_year
  end

  def any?
    base_query.any?
  end

  def any_for_year?
    contributions.any?
  end

  def contribution_years
    @years ||= (base_query.pluck('DISTINCT(EXTRACT(YEAR FROM created_at)::integer)') << current_year).uniq.sort
  end

  def contributions
    base_query.for_year(year)
  end

  private

  def base_query
    user.source_contributions
  end

  def current_year
    Time.zone.now.year
  end
end
