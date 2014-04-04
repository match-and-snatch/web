class Owner::SecondStepsController < Owner::BaseController

  def show
    json_render
  end

  def update
    UserProfileManager.new(@user).update subscription_cost: params[:subscription_cost],
                                         profile_name:      params[:profile_name]
    redirect_to third_step_path
  end
end