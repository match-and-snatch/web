class Admin::TransfersController < Admin::BaseController
  before_filter :load_user!

  def index
    load_transfers
    json_render
  end

  def create
    TransferManager.new(recipient: @user).transfer(amount: params[:amount], descriptor: params[:descriptor])
    load_transfers
    json_replace(template: :index)
  end

  private

   def load_transfers
     @transfers = StripeTransfer.where(user_id: @user.id)
   end

  def load_user!
    @user = User.where(id: params[:profile_owner_id]).first or error(404)
  end
end
