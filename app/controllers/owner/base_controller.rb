class Owner::BaseController < ApplicationController
  before_action :authenticate!
  before_action :load_user

  protected

  def load_user
    @user = current_user.object
    redirect_to profile_path(@user) if @user.has_full_account?
  end
end