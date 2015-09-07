class Admin::PartnersController < Admin::BaseController
  before_action :load_user!
  before_action :load_partner!, only: [:update]

  def search
    @users = Queries::Users.new(user: current_user, query: params[:q]).potential_partners(@user)
    json_replace
  end

  def show
    json_render
  end

  def edit
    json_popup
  end

  def update
    UserProfileManager.new(@user).set_partner!(partner: @partner, partner_fees: params[:partner_fees])
    json_replace template: 'show'
  end

  def confirm_destroy
    json_popup
  end

  def destroy
    UserProfileManager.new(@user).remove_partner!
    json_replace template: 'show'
  end

  private

  def load_user!
    @user = User.where(id: params[:profile_owner_id]).first or error(404)
  end

  def load_partner!
    @partner = User.find(params[:partner_id])
  end
end
