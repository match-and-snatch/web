class UsersController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  layout 'account_info'

  before_filter :authenticate!, :load_user, except: [:index, :create, :show]
  before_filter :redirect_complete, only: :edit

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
    json_redirect finish_profile_path
  end

  # First and second step of registration flow
  def edit
    respond_to do |format|
      format.html # Renders demo profile preview
      format.json { json_render template: 'edit_price_slug' } # Renders second step
    end
  end

  # Second step submission
  def update
    UserProfileManager.new(@user).update(subscription_cost: params[:subscription_cost], slug: params[:slug])
    json_replace template: 'edit_payment_information'
  end

  # Third step submission
  def update_payment_information
    UserProfileManager.new(@user).update_payment_information holder_name:    params[:holder_name],
                                                             routing_number: params[:routing_number],
                                                             account_number: params[:account_number]
    json_redirect account_info_path
  end

  # Shows user dashboard
  def account_info
  end

  def account_settings
    json_render
  end

  def update_general_information
    UserProfileManager.new(@user).update_general_information full_name: params[:full_name],
                                                             slug:      params[:slug],
                                                             email:     params[:email]
    json_success
  end

  def change_password
    UserProfileManager.new(@user).change_password current_password:          params[:current_password],
                                                  new_password:              params[:new_password],
                                                  new_password_confirmation: params[:new_password_confirmation]
    json_success
  end

  def billing_information
    json_render
  end

  def update_bank_account_data
    UserProfileManager.new(@user).update_payment_information holder_name:    params[:holder_name],
                                                             routing_number: params[:routing_number],
                                                             account_number: params[:account_number]
    json_success
  end

  def edit_cc_data
    json_render
  end

  def update_cc_data
    UserProfileManager.new(@user).update_cc_data number:       params[:number],
                                                 cvc:          params[:cvc],
                                                 expiry_month: params[:expiry_month],
                                                 expiry_year:  params[:expiry_year]
    json_success
  end

  def update_name
    UserProfileManager.new(@user).update_full_name params[:full_name]
    json_success
  end

  def update_cost
    UserProfileManager.new(@user).update_subscription_cost params[:subscription_cost]
    json_success
  end

  def update_profile_picture
    UserProfileManager.new(@user).update_profile_picture(params[:transloadit])
    json_replace
  end

  def update_cover_picture
    UserProfileManager.new(@user).update_cover_picture(params[:transloadit])
    json_replace
  end

  def create_profile_page
    UserProfileManager.new(@user).create_profile_page
    json_redirect finish_profile_path
  end

  # Profile page
  def show
    user = User.profile_owners.where(slug: params[:id]).first or error(404)
    @profile = ProfileDecorator.new(user)

    if user == current_user.object
      template = 'owner_view'
    elsif can?(:see, user)
      template = 'show'
    else
      template = 'public_show'
    end

    render action: template, layout: 'profile'
  end

  private

  # Redirects profiles on dashboard if all three registration steps are passed
  def redirect_complete
    redirect_to account_info_path if @user.has_complete_profile?
  end

  def load_user
    @user = current_user.object
  end
end
