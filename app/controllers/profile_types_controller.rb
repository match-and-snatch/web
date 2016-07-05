class ProfileTypesController < ApplicationController
  before_action :authenticate!

  def index
    query = Queries::ProfileTypes.new(user: current_user.object, query: params[:q])
    @profile_types = query.results
    json_replace
  end

  def create
    manager.add_profile_type(params['type'])
    json_replace html: types_html, types_text: types_text_html
  end

  def destroy
    profile_type = ProfileType.where(id: params[:id]).first or error(404)
    manager.remove_profile_type(profile_type)
    json_replace html: types_html, types_text: types_text_html
  end

  def reorder
    manager.reorder_profile_types(params[:ids])
    json_replace html: types_html, types_text: types_text_html
  end

  private

  def manager
    UserProfileManager.new(current_user.object)
  end

  def types_html
    render_to_string(partial: 'list_assigned', locals: {profile_types: current_user.profile_types})
  end

  def types_text_html
    render_to_string(partial: 'profile_types_text', locals: {types_text: current_user.types_text})
  end
end
