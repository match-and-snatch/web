class Admin::PartnersController < Admin::BaseController
  before_filter :load_user!
  before_filter :load_partner!, only: [:create]

  def index
    json_render
  end

  def search
    @users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_replace
  end

  def new
    json_popup
  end

  def create
    UserProfileManager.new(@user).set_partner!(partner: @partner, partner_fees: params[:partner_fees])
    json_replace template: 'index'
  end

  def confirm_removal
    json_popup
  end

  def remove
    UserProfileManager.new(@user).remove_partner!
    json_reload
  end

  private

  def load_user!
    @user = User.where(id: params[:profile_owner_id]).first or error(404)
  end

  def load_partner!
    @partner = User.where(id: params[:partner_id]).first or error(404)
  end
end
