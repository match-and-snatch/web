class AccountInfosController < ApplicationController
  before_filter :authenticate!
  before_filter :load_user

  def show
    layout.title = 'Account - ConnectPal.com'
  end

  def details
    @user = UserStatsDecorator.new(@user)
    json_render
  end

  def settings
    json_render
  end

  def update_general_information
    UserProfileManager.new(@user).update_general_information full_name: params[:full_name],
                                                             slug:      params[:slug],
                                                             email:     params[:email]
    notice('Your account information has been updated.')
    json_reload
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

  def edit_payment_information
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

  def create_profile_page
    UserProfileManager.new(@user).create_profile_page
    json_redirect(@user.passed_profile_steps? ? profile_path(@user) : create_profile_path)
  end

  def delete_profile_page
    UserProfileManager.new(@user).delete_profile_page
    json_reload
  end

  private

  def load_user
    @user = current_user.object
  end
end