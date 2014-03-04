class UsersController < ApplicationController
  before_filter :authenticate!, :load_user, except: [:create, :show]
  before_filter :redirect_complete, only: :edit

  # Registers new user
  def create
    user = AuthenticationManager.new(email:                 params[:email],
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
      format.json { json_render 'edit_price_slug' } # Renders second step
    end
  end

  # Second step submission
  def update
    UserProfileManager.new(@user).update(subscription_cost: params[:subscription_cost], slug: params[:slug])
    json_replace 'edit_payment_information'
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

  # Profile public page
  def show
    @user = User.where(slug: params[:id]).first or error(404)

    if @user == current_user.object
      render action: 'show'
    else
      render action: 'public_show'
    end
  end

  private

  # Redirects profiles on dashboard if all three registration steps are passed
  def redirect_complete
    redirect_to account_info_path if @user.complete_profile?
  end

  def load_user
    @user = current_user.object
  end
end