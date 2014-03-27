class Owner::BaseController < ApplicationController
  before_filter :load_user

  protected

  def load_user
    @user = current_user.object or error(404)
    redirect_to profile_path(@user) if @user.has_complete_profile?
  end
end