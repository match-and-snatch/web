class UsersController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  before_filter :authenticate!, except: %i(index create show)

  def index
    @users = User.profile_owners.with_complete_profile.search_by_full_name(params[:q]).limit(10)
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

  # Profile page
  def show
    user = User.profile_owners.with_complete_profile.where(slug: params[:id]).first or error(404)
    @profile = ProfileDecorator.new(user)

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
    json_success
  end

  def update_cost
    UserProfileManager.new(current_user.object).update_subscription_cost(params[:subscription_cost])
    json_success
  end

  def update_profile_picture
    UserProfileManager.new(current_user.object).update_profile_picture(params[:transloadit])
    json_replace
  end

  def update_cover_picture
    UserProfileManager.new(current_user.object).update_cover_picture(params[:transloadit])
    json_replace
  end

  def update_contacts_info
    UserProfileManager.new(current_user.object).update_contacts_info(params[:contacts_info])
    profile = ProfileDecorator.new(current_user.object)
    json_replace html: render_to_string(partial: 'user_contacts_info_links', locals: {profile: profile})
  end
end
