class Admin::VacationsController < Admin::BaseController
  before_action :load_user!, only: [:history]

  def index
    query = User.profile_owners.
        joins(:events).
        where(events: {action: %w[vacation_mode_enabled vacation_mode_disabled]}).
        where('users.subscribers_count > ?', 0).
        group('users.id')

    if params[:sort_by]
      query = query.order("#{params[:sort_by]} #{params[:sort_direction]}")
    else
      query = query.order(subscribers_count: :desc)
    end
    events = Event.where(action: %w[vacation_mode_enabled vacation_mode_disabled], user_id: query.map(&:id)).group_by(&:user_id)
    @vacations = query.map {|user| VacationsPresenter.new(user: user, events: events[user.id].sort_by(&:created_at))}
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
