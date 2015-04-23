class Api::UsersController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :load_user!, only: %i[show update_profile_name update_profile_picture update_cover_picture update_cost]

  protect(:update_profile_name, :update_profile_picture, :update_cover_picture, :update_cost) { current_user == @user }

  def search
    users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_success(users.map(&method(:user_data)))
  end

  def show
    respond_with_user_data
  end

  # Registers new profile __owner__ (not just subscriber)
  def create
    user = AuthenticationManager.new(
        params.slice(%i(email first_name last_name password)).merge(is_profile_owner: true, password_confirmation: params[:password])
    ).register

    session_manager.login(user.email, params[:password], use_api_token: true)
    json_success user_data(user.reload)
  end

  def update_cost
    manager.update_cost(params[:cost], update_existing_subscriptions: params.bool(:update_existing))
    if manager.cost_change_request_submited?
      notice(:cost_change_request_submited)
    end
    respond_with_user_data
  end

  def update_profile_name
    manager.update_profile_name(params[:name])
    respond_with_user_data
  end

  def update_profile_picture
    manager.update_profile_picture(params[:transloadit])
    respond_with_user_data
  end

  def update_cover_picture
    manager.update_cover_picture(params[:transloadit])
    respond_with_user_data
  end

  private

  def manager
    @manager ||= UserProfileManager.new(@user)
  end

  def load_user!
    @user = User.where(slug: params[:id]).first or error(404)
  end

  def respond_with_user_data
    json_success(user_data(@user.reload))
  end

  def user_data(user)
    {
      access: {
        owner: current_user == user,
        subscribed: current_user.subscribed_to?(user)
      },
      name: user.name,
      slug: user.slug,
      types: user.profile_types.order(:ordering).map(&:title),
      benefits: user.benefits.order(:ordering).map(&:message),
      subscription_cost: user.subscription_cost,
      cost: user.cost,
      profile_picture_url: user.profile_picture_url,
      small_profile_picture_url: user.small_profile_picture_url,
      cover_picture_url: user.cover_picture_url,
      cover_picture_position: user.cover_picture_position,
      api_token: user.api_token
    }
  end
end