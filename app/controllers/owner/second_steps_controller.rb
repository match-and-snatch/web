class Owner::SecondStepsController < Owner::BaseController

  def show
    @profile_types = ProfileType.where(user_id: nil).pluck(:title).sort
    json_render
  end

  def update
    manager.finish_owner_registration(params.slice(:cost, :profile_name, :holder_name, :routing_number, :account_number))
    notice = :congrats unless manager.cost_change_request_submitted?
    json_redirect profile_path(@user.reload.slug), notice: notice
  end

  private

  def manager
    @manager ||= UserProfileManager.new(@user)
  end
end
