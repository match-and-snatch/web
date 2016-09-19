class Api::UsersController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :load_user!, only: %i[show update_profile_name update_profile_picture update_cover_picture update_cover_picture_position update_cost login_as]

  protect(:update_profile_name, :update_profile_picture, :update_cover_picture, :update_cost) { current_user == @user }
  protect(:login_as) { can?(:login_as, @user) }

  def index
    top_users = User.top
    users = Queries::Users.new(user: current_user).grouped_by_first_letter
    json_success api_response.profiles_list_data(top_users, users)
  end

  def search
    users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_success results: users.map { |user| api_response.profile_data(user) }
  end

  def show
    @user = User.profile_owners.with_complete_profile.where(slug: params[:id]).first or error(404)
    json_success api_response.profile_data(@user)
  end

  def fetch_current_user
    json_success api_response.current_user_data
  end

  # Registers new profile __owner__ (not just subscriber)
  def create
    user = AuthenticationManager.new(
        params.slice(%i[email first_name last_name password]).merge(is_profile_owner: true, password_confirmation: params[:password], tos_accepted: params.bool(:tos_accepted))
    ).register
    user = session_manager.login(user.email, params[:password], use_api_token: true)
    json_success user: api_response.current_user_data(user)
  end

  def update_cost
    manager.update_cost(params[:cost], update_existing_subscriptions: params.bool(:update_existing))
    notice(:cost_change_request_submitted) if manager.cost_change_request_submitted?
    json_success cost: @user.cost
  end

  def update_profile_name
    manager.update_profile_name(params[:name])
    json_success profile_name: @user.profile_name
  end

  def update_profile_picture
    manager.update_profile_picture(params[:transloadit])
    json_success api_response.profile_data(@user)
  end

  def update_cover_picture
    manager.update_cover_picture(params[:transloadit])
    json_success api_response.profile_data(@user)
  end

  def update_cover_picture_position
    manager.update_cover_picture_position(params[:cover_picture_position])
    json_success api_response.profile_data(@user)
  end

  def mentions
    @users = Queries::Mentions.new(current_user: current_user, profile_id: params[:profile_id], query: params[:q]).by_name
    json_success mentions: api_response.mentions_data(@users)
  end

  def login_as
    session_manager.login_as(current_user.object, @user)
    json_success user: api_response.current_user_data(@user)
  end

  private

  def manager
    @manager ||= UserProfileManager.new(@user)
  end

  def load_user!
    @user = User.where(slug: params[:id]).first or error(404)
  end
end
