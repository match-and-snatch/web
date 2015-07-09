class Api::ProfileInfosController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :load_user!

  protect(:create_profile, :create_profile_page,
          :settings, :details, :update_bank_account_data,
          :enable_notifications_debug, :disable_notifications_debug,
          :enable_rss, :disable_rss,
          :enable_downloads, :disable_downloads,
          :enable_itunes, :disable_itunes,
          :enable_vacation_mode, :disable_vacation_mode,
          :enable_contributions, :disable_contributions,
          :update_slug, :update_welcome_media, :remove_welcome_media) { current_user.authorized? }

  def create_profile
    manager.create_profile_page
    user = manager.finish_owner_registration(params.slice(:cost, :profile_name))
    json_success api_response.current_user_data(user)
  end

  def create_profile_page
    user = manager.create_profile_page
    json_success api_response.current_user_data(user)
  end

  def settings
    respond_with_settings_data
  end

  def details
    json_success api_response.profile_details_data
  end
  
  def update_bank_account_data
    manager.update_payment_information params.slice(:holder_name, :routing_number, :account_number, :paypal_email).merge(prefer_paypal: params.bool(:prefer_paypal))
    respond_with_settings_data
  end

  def enable_notifications_debug
    manager.enable_notifications_debug
    json_success notifications_debug_enabled: @user.notifications_debug_enabled
  end

  def disable_notifications_debug
    manager.disable_notifications_debug
    json_success notifications_debug_enabled: @user.notifications_debug_enabled
  end

  def enable_rss
    manager.enable_rss
    respond_with_settings_data
  end

  def disable_rss
    manager.disable_rss
    respond_with_settings_data
  end

  def enable_downloads
    manager.enable_downloads
    respond_with_settings_data
  end

  def disable_downloads
    manager.disable_downloads
    respond_with_settings_data
  end

  def enable_itunes
    manager.enable_itunes
    respond_with_settings_data
  end

  def disable_itunes
    manager.disable_itunes
    respond_with_settings_data
  end

  def enable_contributions
    manager.enable_contributions
    respond_with_settings_data
  end

  def disable_contributions
    manager.disable_contributions
    respond_with_settings_data
  end

  def enable_vacation_mode
    manager.enable_vacation_mode(reason: params[:vacation_message])
    json_success vacation_enabled: @user.vacation_enabled?
  end

  def disable_vacation_mode
    manager.disable_vacation_mode
    json_success vacation_enabled: @user.vacation_enabled?
  end

  def update_slug
    manager.update_slug params[:slug]
    notice :slug_updated
    json_success slug: @user.slug
  end

  def update_welcome_media
    manager.update_welcome_media(params[:transloadit])
    respond_with_settings_data
  end

  def remove_welcome_media
    manager.remove_welcome_media!
    respond_with_settings_data
  end

  private

  def respond_with_settings_data
    json_success api_response.profile_settings_data(@user)
  end

  # @return [UserProfileManager]
  def manager
    @manager ||= UserProfileManager.new(@user)
  end

  def load_user!
    @user = current_user.object
  end
end
