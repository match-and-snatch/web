class Dashboard::Admin::TransfersController < Dashboard::Admin::BaseController
  before_action :load_user!

  def index
    load_transfers
    json_render
  end

  def create
    TransferManager.new(recipient: @user).transfer(amount: params[:amount], descriptor: params[:descriptor], month: params[:date]['month'])
    load_transfers
    json_replace(template: :index)
  end

  private

   def load_transfers
     @months = BillingPeriodsPresenter.new(user: @user)
   end

  def load_user!
    @user = User.where(id: params[:profile_owner_id]).first or error(404)
  end
end
