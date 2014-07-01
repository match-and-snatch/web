class Admin::ProfileOwnersController < Admin::BaseController
  before_filter :load_user!, only: :show

  def index
    query = User.profile_owners.includes(:profile_types).where('subscription_cost IS NOT NULL').limit(1000)
    query = query.joins(:source_payments).
      select('users.*, SUM(payments.amount) as transfer').
      group('users.id, payments.amount')
    if params[:sort_by]
      query = query.order("#{params[:sort_by]} #{params[:sort_direction]}")
    else
      query = query.order('transfer DESC')
    end
    @users = query.map { |user| ProfileDecorator.new(user) }
    json_render
  end

  def show
    @user = UserStatsDecorator.new(@user)
    json_render
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end
