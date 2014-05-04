class UsersController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  before_filter :authenticate!, except: %i(index mentions create show activate)

  def index
    @users = User.profile_owners.with_complete_profile.search_by_full_name(params[:q]).limit(10)
    json_replace
  end

  def mentions
    @users = User.where.not(id: current_user.id).search_by_full_name(params[:q]).limit(5)
    json_replace
  end

  # Registers new profile __owner__ (not just subscriber)
  def create
    user = AuthenticationManager.new(is_profile_owner:      true,
                                     email:                 params[:email],
                                     first_name:            params[:first_name],
                                     last_name:             params[:last_name],
                                     password:              params[:password],
                                     password_confirmation: params[:password_confirmation]).register
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

  # Profile page
  def show
    user = User.profile_owners.with_complete_profile.where(slug: params[:id]).first or error(404)
    @profile = ProfileDecorator.new(user)

    layout.title = "#{@profile.name} - ConnectPal.com"

    if current_user.can?(:manage, user)
      template = 'owner_view'
    elsif can?(:see, user)
      template = 'show'
    else
      template = 'public_show'
    end

    render action: template
  end

  def update_name
    UserProfileManager.new(current_user.object).update_profile_name(params[:profile_name])
    json_success notice: 'Successfully updated your name.'
    #json_reload
  end

  def update_cost
    manager = UserProfileManager.new(current_user.object)
    manager.update_cost(params[:cost])

    if manager.unable_to_change_cost?
      notice(:unable_to_change_cost)
    end

    json_reload
  end

  def update_profile_picture
    UserProfileManager.new(current_user.object).update_profile_picture(params[:transloadit])
    json_replace html: render_to_string(partial: 'profile_picture')
  end

  def update_cover_picture
    UserProfileManager.new(current_user.object).update_cover_picture(params[:transloadit])
    json_replace html: render_to_string(partial: 'cover_picture')
  end

  def update_contacts_info
    UserProfileManager.new(current_user.object).update_contacts_info(params[:contacts_info])
    profile = ProfileDecorator.new(current_user.object)
    json_replace html: render_to_string(partial: 'user_contacts_info_links', locals: {profile: profile})
  end

  def update_cover_picture_position
    UserProfileManager.new(current_user.object).update_cover_picture_position(params[:cover_picture_possition])
    json_success
  end
end
