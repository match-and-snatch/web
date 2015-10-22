class Api::UsersController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :load_user!, only: %i[show update_profile_name update_profile_picture update_cover_picture update_cover_picture_position update_cost]

  protect(:update_profile_name, :update_profile_picture, :update_cover_picture, :update_cost) { current_user == @user }

  def index
    top_users = User.top
    users = Queries::Users.new(user: current_user).grouped_by_first_letter
    json_success api_response.profiles_list_data(top_users, users)
  end

  def search
    users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_success results: users.map(&method(:user_data))
  end

  def show
    @user = User.profile_owners.with_complete_profile.where(slug: params[:id]).first or error(404)
    respond_with_user_data
  end

  def fetch_current_user
    json_success api_response.current_user_data
  end

  # Registers new profile __owner__ (not just subscriber)
  def create
    user = AuthenticationManager.new(
        params.slice(%i(email first_name last_name password)).merge(is_profile_owner: true, password_confirmation: params[:password])
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
    respond_with_user_data
  end

  def update_cover_picture
    manager.update_cover_picture(params[:transloadit])
    respond_with_user_data
  end

  def update_cover_picture_position
    manager.update_cover_picture_position(params[:cover_picture_position])
    respond_with_user_data
  end

  def mentions
    @users = User.mentions(current_user: current_user, profile_id: params[:profile_id], query: params[:q]).to_a
    json_success api_response.mentions_data(@users)
  end

  private

  def manager
    @manager ||= UserProfileManager.new(@user)
  end

  def load_user!
    @user = User.where(slug: params[:id]).first or error(404)
  end

  def respond_with_user_data
    json_success(user_data(ProfileDecorator.new(@user.reload)))
  end

  def user_data(user)
    extended_params = {
      types: user.profile_types.order(:ordering).map(&:title),
      benefits: user.benefits.order(:ordering).map(&:message),
      subscription_cost: user.subscription_cost,
      cost: user.cost,
      profile_picture_url: user.profile_picture_url,
      small_profile_picture_url: user.small_profile_picture_url,
      cover_picture_url: user.cover_picture_url,
      cover_picture_position: user.cover_picture_position,
      cover_picture_position_perc: user.cover_picture_position_perc,
      cover_picture_height: user.cover_picture_height,
      rss_enabled: user.rss_enabled?,
      vacation_enabled: user.vacation_enabled?,
      vacation_message: user.vacation_message,
      contributions_enabled: user.contributions_enabled?,
      has_mature_content: user.has_mature_content?,
      cost_approved: user.cost_approved?,
      welcome_media: {
        welcome_audio: api_response.welcome_media_data(user.welcome_audio),
        welcome_video: api_response.welcome_media_data(user.welcome_video)
      },
      custom_welcome_message: user.profile_page_data.welcome_box,
      special_offer_message: user.profile_page_data.special_offer,
      locked: user.locked?,
      dialogue_id: user.dialogues.by_user(current_user.object).first.try(:id)
    }
    api_response.basic_profile_data(user).merge(extended_params)
  end
end
