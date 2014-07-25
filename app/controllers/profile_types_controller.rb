class ProfileTypesController < ApplicationController
  before_filter :authenticate!

  def index
    query = Queries::ProfileTypes.new(user: current_user.object, query: params[:q])
    @profile_types = query.results
    json_replace
  end

  def create
    UserProfileManager.new(current_user.object).add_profile_type(params['type'])
    json_replace html: types_html
  end

  def destroy
    profile_type = ProfileType.where(id: params[:id]).first or error(404)
    UserProfileManager.new(current_user.object).remove_profile_type(profile_type)
    json_replace html: types_html
  end

  private

  def types_html
    render_to_string(partial: 'list_assigned', locals: {profile_types: current_user.profile_types})
  end
end
