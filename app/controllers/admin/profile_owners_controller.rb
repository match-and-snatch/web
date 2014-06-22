class Admin::ProfileOwnersController < Admin::BaseController
  before_filter :load_user!, only: :show

  def index
    @users = User.profile_owners.order('created_at DESC').includes(:profile_types).limit(1000).map { |user| ProfileDecorator.new(user) }
    json_render
  end

  def show
    @user = UserStatsDecorator.new(@user)

    begin
      @payments = []
    #@payments = Stripe::Transfer.all(limit: 3)
    rescue
      @payments = []
    end
    json_render
  end

  private

  def load_user!
    @user = User.where(id: params[:id]).first or error(404)
  end
end
