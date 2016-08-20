class VacationsPresenter
  include Enumerable

  attr_reader :user

  # @param user [User]
  def initialize(user: nil, events: nil)
    @user = user
    @events = events
  end

  def each(&block)
    collection.each(&block)
  end

  def collection
    events.in_groups_of(2).map do |pair|
      VacationPeriod.new pair.first, pair.last
    end
  end

  private

  def events
    @events ||= user.events.where(action: %w[vacation_mode_enabled vacation_mode_disabled]).order(:created_at)
  end

  class VacationPeriod
    attr_reader :start_vacation, :finish_vacation

    def initialize(start_vacation, finish_vacation)
      @start_vacation = start_vacation
      @finish_vacation = finish_vacation
    end

    def start_date
      start.to_date.to_s(:long) if start
    end

    def finish_date
      finish.to_date.to_s(:long) if finish
    end

    def length
      finish - start if finish && start
    end

    def affected_users_count
      @finish_vacation.data['affected_users_count'] if @finish_vacation
    end

    private

    def start
      start_vacation.try :created_at
    end

    def finish
      finish_vacation.try :created_at
    end
  end
end
