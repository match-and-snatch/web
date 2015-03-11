class UsersController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  before_filter :authenticate!, except: %i(index search mentions create show activate sample)
  before_filter :redirect_invalid_slug, only: :show

  def index
    layout.title = 'ConnectPal.com - Profile Directory'
    @users = Queries::Users.new(user: current_user).grouped_by_first_letter
    @jane = User.find_by_registration_token('bRxirxcbMuLQdB3rzlA-aQ')
  end

  def search
    @users = Queries::Users.new(user: current_user, query: params[:q]).profile_owners_by_text
    json_replace
  end

  def mentions
    @users = User.where.not(id: current_user.id).search_by_text_fields(params[:q]).limit(5).to_a
    json_replace
  end

  # Registers new profile __owner__ (not just subscriber)
  def create
    user = AuthenticationManager.new(
      params.slice(%i(email first_name last_name password password_confirmation)).merge(is_profile_owner: true)
    ).register

    session_manager.login(user.email, params[:password])
    json_redirect create_profile_path
  end

  # Approves user's email address
  def activate
    AuthenticationManager.new.activate(params[:token])
    notice(:activated)
  rescue ManagerError
    notice(:invalid_token)
  ensure
    redirect_to root_path
  end

  def sample
    return redirect_to '/sampleprofile' if tablet_device?
  end

  # Profile page
  def show
    user = User.profile_owners.with_complete_profile.where(slug: params[:id]).first or error(404)
    @profile = ProfileDecorator.new(user)

    layout.title = "#{@profile.name} - ConnectPal.com"

    if current_user.can?(:manage, user)
      @profile_types = ProfileType.where(user_id: nil).order(:title).pluck(:title)
      template = 'owner_view'
    elsif can?(:see, user)
      template = 'show'
    else
      if current_user.billing_failed?
        notice(:billing_failed)
        template = 'billing_failed_view'
      else
        template = 'public_show'
      end
    end

    if mobile_phone_device?
      UserManager.new(current_user.object).save_last_visited_profile(user)
    end

    render action: template
  end

  def update_name
    UserProfileManager.new(current_user.object).update_profile_name(params[:profile_name])
    json_success notice: 'Successfully updated your name.'
  end

  def update_cost
    manager = UserProfileManager.new(current_user.object)
    manager.update_cost(params[:cost], update_existing_subscriptions: params.bool(:update_existing))

    if manager.cost_change_request_submited?
      notice(:cost_change_request_submited)
    end

    json_reload
  end

  def update_profile_picture
    UserProfileManager.new(current_user.object).update_profile_picture(params[:transloadit])
    json_replace partial: 'profile_picture'
  end

  def delete_profile_picture
    UserProfileManager.new(current_user.object).delete_profile_picture
    json_replace partial: 'profile_picture'
  end

  def update_cover_picture
    UserProfileManager.new(current_user.object).update_cover_picture(params[:transloadit])
    json_replace partial: 'cover_picture'
  end

  def delete_cover_picture
    UserProfileManager.new(current_user.object).delete_cover_picture
    json_replace partial: 'cover_picture'
  end

  def edit_welcome_media
    json_render
  end

  def update_welcome_media
    UserProfileManager.new(current_user.object).update_welcome_media(params[:transloadit])
    json_replace partial: 'welcome_media'
  end

  def update_contacts_info
    UserProfileManager.new(current_user.object).update_contacts_info(params[:contacts_info])
    profile = ProfileDecorator.new(current_user.object)
    json_replace partial: 'user_contacts_info_links', locals: {profile: profile}
  end

  def update_cover_picture_position
    UserProfileManager.new(current_user.object).update_cover_picture_position(params[:cover_picture_position])
    json_success
  end

  def remove_welcome_media
    UserProfileManager.new(current_user.object).remove_welcome_media!
    json_replace partial: 'welcome_media'
  end

  private

  def redirect_invalid_slug
    redirect_to profile_path(params[:id].downcase), status: 301 if /[A-Z]/.match(params[:id])
  end
end
