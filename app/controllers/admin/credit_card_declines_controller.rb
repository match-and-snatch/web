class Admin::CreditCardDeclinesController < Admin::BaseController

  def index
    @declines = CreditCardDecline.order('credit_card_declines.created_at DESC').includes(:user).all
    json_render
  end

  def search
    @users = User.where(email: params[:q].try(:strip))
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

  private

  def manager

  end
end