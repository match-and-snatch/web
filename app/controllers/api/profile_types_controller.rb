class Api::ProfileTypesController < Api::BaseController
  before_action :load_profile_type!, only: [:destroy]

  protect { current_user.authorized? }

  def create
    manager.add_profile_type(params[:type])
    json_success profile_types_data
  end

  def destroy
    manager.remove_profile_type(@profile_type)
    json_success profile_types_data
  end

  private

  def profile_types_data
    {profile_types: current_user.object.profile_types.map { |profile_type| api_response.profile_type_data(profile_type) }}
  end

  def manager
    UserProfileManager.new(current_user.object)
  end

  def load_profile_type!
    @profile_type = ProfileType.where(id: params[:id]).first or error(404)
  end
end
