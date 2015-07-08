class Owner::SecondStepsController < Owner::BaseController

  def show
    @profile_types = ProfileType.where(user_id: nil).pluck(:title).sort
    json_render
  end

  def update
    UserProfileManager.new(@user).
      finish_owner_registration(params.slice(:cost, :profile_name, :holder_name, :routing_number, :account_number))

    json_redirect profile_path(@user.reload.slug), notice: :congrats
  end
end
