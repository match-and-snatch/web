class Admin::TopProfilesController < Admin::BaseController
  before_filter :load_users, except: :search

  def index
    json_render
  end

  def search
    @users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_replace
  end

  def create
    TopProfile.create!(user_id: params[:user_id])
    json_replace template: 'index'
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

  def load_users
    @users = User.top
  end
end