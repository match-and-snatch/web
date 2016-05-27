class Dashboard::Admin::RefundsController < Dashboard::Admin::BaseController
  def index
    @months = Refund.pluck("DISTINCT date_trunc('month', refunded_at)").sort
    @date = Chronic.parse(params[:month])

    query = Refund.includes(:user)
    query = query.joins(:user).where("users.full_name ILIKE '%#{params[:profile]}%'") if params[:profile].present?
    query = query.where(refunded_at: @date.beginning_of_month..@date.end_of_month) if @date
    query = if params[:sort_by]
              query.order("#{params[:sort_by]} #{params[:sort_direction]}")
            else
              query.order(refunded_at: :desc)
            end

    @refunds = query.page(params[:page]).per(100)
    json_render
  end
end
