class Owner::SecondStepsController < Owner::BaseController

  def show
    @profile_types = ProfileType.where(user_id: nil).pluck(:title).sort
    json_render
  end

  def update
    UserProfileManager.new(@user).update cost:           params[:cost],
                                         profile_name:   params[:profile_name],
                                         holder_name:    params[:holder_name],
                                         routing_number: params[:routing_number],
                                         account_number: params[:account_number]
    if @user.has_full_account?
      notice(:congrats)
      json_redirect profile_path(@user.reload.slug)
    else
      json_success notice: render_to_string(partial: 'notice')
    end
  end
end
