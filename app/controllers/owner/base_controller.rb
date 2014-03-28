class Owner::BaseController < ApplicationController
  before_filter :authenticate!
  before_filter :load_user

  protected

  def load_user
    @user = current_user.object
    redirect_to profile_path(@user) if @user.has_complete_profile?
  end
end