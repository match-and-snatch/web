class Api::BenefitsController < Api::BaseController
  before_action :load_user!

  protect(:create) { current_user.authorized? }

  def create
    UserProfileManager.new(@user).update_benefits(params['benefits'])
    json_success benefits: @user.benefits.order(:ordering).pluck(:message)
  end

  private

  def load_user!
    @user = current_user.object or error(404)
  end
end