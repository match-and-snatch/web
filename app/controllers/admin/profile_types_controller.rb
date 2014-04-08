class Admin::ProfileTypesController < Admin::BaseController
  before :destroy, :load_profile_type!

  def index
    @profile_types = ProfileType.limit(100).all.to_a
    json_render
  end

  def create
    @profile_type = ProfileTypeManager.new.create(title: params[:title])
    json_reload
  end

  def destroy
    @profile_type.destroy
    json_reload
  end

  private

  def load_profile_type!
    @profile_type = ProfileType.where(id: params[:id]).first or error(404)
  end
end