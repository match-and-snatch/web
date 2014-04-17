class Owner::SecondStepsController < Owner::BaseController

  def show
    json_render
  end

  def update
    UserProfileManager.new(@user).update cost:         params[:cost],
                                         profile_name: params[:profile_name]
    json_redirect profile_path(@user.reload.slug)
  end
end