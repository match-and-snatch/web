class Dashboard::Admin::PotentialViolatorsController < Dashboard::Admin::BaseController

  def index
    query = User.select("users.*, COUNT(subscriptions.id) as subscriptions_count").joins(:subscriptions)
      .includes(subscriptions: :target_user)
      .group('users.id').having('COUNT(subscriptions.id) >= 8')

    if params[:sort_by]
      query = query.order("#{params[:sort_by]} #{params[:sort_direction]}")
    else
      query = query.order(recent_subscription_at: :desc)
    end

    if params[:active]
      query = query.where('users.locked = ?', false)
    elsif params[:locked]
      query = query.where('users.locked = ?', true)
    end

    @users = query.page(params[:page]).per(20)

    json_render
  end
end
