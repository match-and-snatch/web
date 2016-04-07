class Dashboard::Admin::RecentlyChangedEmailsController < Dashboard::Admin::BaseController
  def index
    query = User.profile_owners
                .where.not(users: {subscription_cost: nil})
                .where('gross_sales > ?', 9900)
                .where(email_updated_at: period)

    query = if params[:sort_by]
              query.order("#{params[:sort_by]} #{params[:sort_direction]}")
            else
              query.order(gross_sales: :desc)
            end

    @users = query.page(params[:page]).per(25)

    json_render
  end

  private

  def period
    time = params[:filter] == 'previous_month' ? Time.zone.now.prev_month  : Time.zone.now
    time.beginning_of_month..time.end_of_month
  end
end
