class AccountInfosController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

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

  def update_account_picture
    manager.update_account_picture(params[:transloadit])
    json_replace html: render_to_string(partial: 'account_picture')
  end

  def update_general_information
    manager.update_general_information full_name:    params[:full_name],
                                       company_name: params[:company_name],
                                       email:        params[:email]
    json_success notice: :account_updated
  end

  def update_slug
    manager.update_slug params[:slug]
    notice(:slug_updated)
    json_reload
  end

  def change_password
    manager.change_password current_password:          params[:current_password],
                            new_password:              params[:new_password],
                            new_password_confirmation: params[:new_password_confirmation]
    json_success notice: :updated_password
  end

  def billing_information
    json_render
  end

  def edit_payment_information
    json_render
  end

  def update_bank_account_data
    manager.update_payment_information holder_name:    params[:holder_name],
                                       routing_number: params[:routing_number],
                                       account_number: params[:account_number]
    json_success
  end

  def edit_cc_data
    json_render
  end

  def update_cc_data
    manager.update_cc_data number:       params[:number],
                           cvc:          params[:cvc],
                           expiry_month: params[:expiry_month],
                           expiry_year:  params[:expiry_year]
    json_success
  end

  def create_profile_page
    manager.create_profile_page
    json_redirect(@user.passed_profile_steps? ? profile_path(@user) : create_profile_path)
  end

  def confirm_profile_page_removal
    json_success popup: render_to_string(action: 'confirm_profile_page_removal', layout: false)
  end

  def delete_profile_page
    manager.delete_profile_page
    json_reload
  end

  def enable_rss
    manager.enable_rss
    json_success
  end

  def disable_rss
    manager.disable_rss
    json_success
  end

  def enable_downloads
    manager.enable_downloads
    json_success
  end

  def disable_downloads
    manager.disable_downloads
    json_success
  end

  def enable_itunes
    manager.enable_itunes
    json_success
  end

  def disable_itunes
    manager.disable_itunes
    json_success
  end

  private

  # @return [UserProfileManager]
  def manager
    UserProfileManager.new(current_user.object)
  end

  def load_user
    @user = current_user.object
  end
end
