class Users::UploadsController < ApplicationController
  include Transloadit::Rails::ParamsDecoder
  before_filter :load_user!

  def create
    UserProfileManager.new(@user).update_profile_picture(params[:transloadit])
    json_replace
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end