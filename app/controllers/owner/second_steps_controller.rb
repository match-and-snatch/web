class Owner::SecondStepsController < Owner::BaseController

  def show
    json_render
  end

  def update
    UserProfileManager.new(@user).update cost:           params[:cost],
                                         profile_name:   params[:profile_name],
                                         holder_name:    params[:holder_name],
                                         routing_number: params[:routing_number],
                                         account_number: params[:account_number]
    notice(:congrats)
    json_redirect profile_path(@user.reload.slug)
  end
end