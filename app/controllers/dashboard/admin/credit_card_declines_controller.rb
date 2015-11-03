class Dashboard::Admin::CreditCardDeclinesController < Dashboard::Admin::BaseController

  def index
    @declines = CreditCardDecline.order('credit_card_declines.created_at DESC').includes(:user).all
    json_render
  end

  def search
    @users = Queries::Users.new(user: current_user.object, query: params[:q]).by_email
    json_replace
  end

  def create
    UserProfileManager.new(User.where(email: params[:email]).first).decline_credit_card
    json_reload
  end

  def destroy
    user = CreditCardDecline.find(params[:id]).user
    UserProfileManager.new(user).restore_credit_card
    json_reload
  end
end
