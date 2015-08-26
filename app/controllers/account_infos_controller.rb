class AccountInfosController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  before_action :authenticate!
  before_action :load_user

  def show
    layout.title = 'Account - ConnectPal.com'

    if params[:profile]
      if @user.has_profile_page?
        return redirect_to profile_path(@user.slug)
      else
        return redirect_to(create_profile_path)
      end
    end
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
    json_replace partial: 'account_picture'
  end

  def update_general_information
    manager.update_general_information(params.slice(:full_name, :company_name, :email))
    json_success notice: :account_updated
  end

  def update_slug
    manager.update_slug params[:slug]
    json_reload notice: :slug_updated
  end

  def change_password
    manager.change_password(params.slice(:current_password, :new_password, :new_password_confirmation))
    json_success notice: :updated_password
  end

  def billing_information
    @subscriptions = SubscriptionsPresenter.new(user: @user)
    @contributions = Contribution.where(user_id: @user.id, recurring: true).limit(200)
    json_render
  end

  def edit_payment_information
    json_render
  end

  def update_bank_account_data
    manager.update_payment_information(params.slice(:holder_name, :routing_number, :account_number, :paypal_email).merge(prefer_paypal: params.bool(:prefer_paypal)))
    json_reload notice: 'Successfully updated your payout information'
  end

  def edit_cc_data
    json_render
  end

  def update_cc_data
    manager.update_cc_data(params.slice(:number, :cvc, :expiry_month, :expiry_year, :zip, :city, :state, :address_line_1, :address_line_2))
    json_reload notice: :updated_cc_data
  end

  def create_profile_page
    manager.create_profile_page
    json_redirect(@user.passed_profile_steps? ? profile_path(@user) : create_profile_path)
  end

  def confirm_profile_page_removal
    json_popup
  end

  def delete_profile_page
    manager.delete_profile_page
    json_reload notice: (manager.delete_profile_page_request_submited? ? :delete_profile_page_request_submited : :profile_page_deleted)
  end

  def enable_rss
    manager.enable_rss
    json_success
  end

  def disable_rss
    manager.disable_rss
    json_success
  end

  def enable_contributions
    manager.enable_contributions
    json_success
  end

  def disable_contributions
    manager.disable_contributions
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

  def enable_notifications_debug
    manager.enable_notifications_debug
    json_success
  end

  def disable_notifications_debug
    manager.disable_notifications_debug
    json_success
  end

  def confirm_vacation_mode_activation
    json_popup
  end

  def confirm_vacation_mode_deactivation
    json_popup
  end

  def enable_vacation_mode
    manager.enable_vacation_mode(reason: params[:vacation_message])
    json_reload
  end

  def disable_vacation_mode
    manager.disable_vacation_mode
    json_reload
  end

  private

  # @return [UserProfileManager]
  def manager
    @manager ||= UserProfileManager.new(current_user.object)
  end

  def load_user
    @user = current_user.object
  end
end
