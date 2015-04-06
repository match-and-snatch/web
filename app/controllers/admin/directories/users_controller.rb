class Admin::Directories::UsersController < Admin::BaseController
  before_action :load_user!

  def toggle
    manager.toggle
    json_replace
  end

  private

  def manager
    @manager ||= UserProfileManager.new(@user)
  end

  def load_user!
    @user = User.where(slug: params[:id]).first or error(404)
  end
end
