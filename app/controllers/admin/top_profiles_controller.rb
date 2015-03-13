class Admin::TopProfilesController < Admin::BaseController
  before_filter :load_users, except: :search
  before_filter :load_user, only: [:create]
  before_filter :load_top_profile, only: [:edit, :update]

  def index
    json_render
  end

  def search
    @users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_replace
  end

  def create
    @user.create_top_profile!(profile_name: @user.profile_name,
                              profile_types: @user.profile_types.first.try(:title))
    json_replace template: 'index'
  end

  def edit
    json_popup
  end

  def update
    @top_profile.update(params.slice(:profile_name, :profile_types))
    json_replace partial: 'profiles_list', locals: {users: @users}
  end

  def update_list
    TopProfile.update_list(params[:ids])
    json_success
  end

  def destroy
    TopProfile.find(params[:id]).destroy!

    if params[:template]
      json_replace partial: params[:template], locals: {users: @users}
    else
      json_replace template: 'index'
    end
  end

  private

  def load_top_profile
    @top_profile = TopProfile.find(params[:id])
  end

  def load_user
    @user = User.includes(:profile_types).find(params[:user_id])
  end

  def load_users
    @users = User.top
  end
end