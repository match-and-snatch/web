class BenefitsController < ApplicationController
  before_filter :load_user!

  def create
    UserProfileManager.new(@user).update_benefits(params['benefits'])
    @benefits = ProfileDecorator.new(@user).benefits
    json_replace
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end