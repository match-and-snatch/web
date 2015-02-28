class Admin::TopProfilesController < Admin::BaseController
  before_filter :load_users, except: :search

  def index
  end

  def search
    @users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_replace
  end

  def create
    TopProfile.create!(params[:user_id])
    json_replace template: 'index'
  end

  def update_list
    TopProfile.update_list(params[:user_ids])
    json_replace template: 'index'
  end

  def destroy
    TopProfile.find(params[:id]).destroy!
    json_replace template: 'index'
  end

  private

  def load_users
    @users = User.top
  end
end