class Admin::VacationsController < Admin::BaseController
  before_action :load_user!, only: [:history]

  def index
    events = Event.where(action: %w[vacation_mode_enabled vacation_mode_disabled])
               .joins(:user).where('users.subscribers_count > 0')
               .preload(:user)
               .group_by(&:user)
               .sort_by { |_, events| events.max_by(&:created_at) }

    @vacations = events.map do |user, events|
      VacationsPresenter.new(user: user, events: events.sort_by(&:created_at))
    end

    json_render
  end

  def history
    @vacations = VacationsPresenter.new(user: @user)
    json_render
  end

  private

  def load_user!
    @user = User.where(id: params[:profile_owner_id]).first or error(404)
  end
end
