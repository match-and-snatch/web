class ProfileTypesController < ApplicationController
  before_filter :authenticate!

  def index
    query = Queries::ProfileTypes.new(user: current_user.object, query: params[:q])
    @profile_types = query.results
    json_replace
  end

  def create
    profile_type = ProfileType.where(id: params[:profile_type_id]).first or error(404)
    UserProfileManager.new(current_user.object).add_profile_type(profile_type)
    json_replace
  end
end