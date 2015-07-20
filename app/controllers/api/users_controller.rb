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
    json_success(users.map(&method(:user_data)))
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
    AuthenticationManager.new(
        params.slice(%i(email first_name last_name password)).merge(is_profile_owner: true, password_confirmation: params[:password])
    ).register
    json_success
  end

  def update_cost
    manager.update_cost(params[:cost], update_existing_subscriptions: params.bool(:update_existing))
    notice(:cost_change_request_submited) if manager.cost_change_request_submited?
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
    @users = User.where.not(id: current_user.id).search_by_text_fields(params[:q]).limit(5).to_a
    json_success mentions_data(@users)
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

  def mentions_data(users = [])
    users.map do |user|
      {
          id: user.id,
          name: user.name,
          slug: user.slug,
          picture_url: user.comment_picture_url
      }
    end
  end

  def user_data(user)
    {
      access: {
        owner: current_user == user,
        subscribed: current_user.subscribed_to?(user),
        billing_failed: current_user.billing_failed?
      },
      id: user.id,
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
      cover_picture_position_perc: user.cover_picture_position_perc,
      cover_picture_height: user.cover_picture_height,
      downloads_enabled: user.downloads_enabled?,
      itunes_enabled: user.itunes_enabled?,
      rss_enabled: user.rss_enabled?,
      api_token: user.api_token,
      vacation_enabled: user.vacation_enabled?,
      vacation_message: user.vacation_message,
      contributions_enabled: user.contributions_enabled,
      has_mature_content: user.has_mature_content?,
      welcome_media: {
        welcome_audio: welcome_media_data(user.welcome_audio),
        welcome_video: welcome_media_data(user.welcome_video)
      },
      dialogue_id: user.dialogues.by_user(current_user.object).first.try(:id)
    }
  end

  def welcome_media_data(upload)
    return {} unless upload

    common_data = {
        id: upload.id,
        file_url: upload.rtmp_path,
        preview_url: upload.preview_url,
        original_url: upload.original_url
    }
    video_data = if upload.video?
                   playlist_url = if upload.low_quality_playlist_url
                                    playlist_video_url(upload.id, format: 'm3u8')
                                  end
                   {
                       hdfile_url:   upload.hd_rtmp_path,
                       playlist_url: playlist_url
                   }
                 else
                   {}
                 end
    common_data.merge(video_data)
  end
end
