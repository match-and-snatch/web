class Api::ProfileInfosController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :load_user!

  protect(:create_profile, :settings, :update_bank_account_data,
          :enable_rss, :disable_rss,
          :enable_downloads, :disable_downloads,
          :enable_itunes, :disable_itunes,
          :enable_vacation_mode, :disable_vacation_mode,
          :enable_contributions, :disable_contributions,
          :update_welcome_media, :remove_welcome_media) { current_user.authorized? }

  def create_profile
    user = manager.update(params.slice(:cost, :profile_name))
    json_success user_data(user)
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
    json_success
  end

  def disable_vacation_mode
    manager.disable_vacation_mode
    json_success
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

  def user_data(user)
    {
        id: user.id,
        slug: user.slug,
        email: user.email,
        created_at: user.created_at,
        updated_at: user.updated_at,
        full_name: user.full_name,
        subscription_cost: user.subscription_cost,
        holder_name: user.holder_name,
        routing_number: user.routing_number,
        account_number: user.account_number,
        stripe_user_id: user.stripe_user_id,
        stripe_card_id: user.stripe_card_id,
        last_four_cc_numbers: user.last_four_cc_numbers,
        card_type: user.card_type,
        profile_picture_url: user.profile_picture_url,
        original_profile_picture_url: user.original_profile_picture_url,
        cover_picture_url: user.cover_picture_url,
        original_cover_picture_url: user.original_cover_picture_url,
        is_profile_owner: user.is_profile_owner,
        has_complete_profile: user.has_complete_profile,
        profile_name: user.profile_name,
        is_admin: user.is_admin,
        contacts_info: user.contacts_info,
        auth_token: user.auth_token,
        cover_picture_position: user.cover_picture_position,
        subscription_fees: user.subscription_fees,
        cost: user.cost,
        has_public_profile: user.has_public_profile,
        company_name: user.company_name,
        small_profile_picture_url: user.small_profile_picture_url,
        account_picture_url: user.account_picture_url,
        small_account_picture_url: user.small_account_picture_url,
        original_account_picture_url: user.original_account_picture_url,
        cost_changed_at: user.cost_changed_at,
        activated: user.activated,
        registration_token: user.registration_token,
        rss_enabled: user.rss_enabled,
        downloads_enabled: user.downloads_enabled,
        itunes_enabled: user.itunes_enabled,
        profile_types_text: user.profile_types_text,
        subscribers_count: user.subscribers_count,
        billing_failed: user.billing_failed,
        stripe_recipient_id: user.stripe_recipient_id,
        billing_failed_at: user.billing_failed_at,
        vacation_enabled: user.vacation_enabled,
        vacation_message: user.vacation_message,
        last_visited_profile_id: user.last_visited_profile_id,
        vacation_enabled_at: user.vacation_enabled_at,
        billing_address_city: user.billing_address_city,
        billing_address_state: user.billing_address_state,
        billing_address_zip: user.billing_address_zip,
        billing_address_line_1: user.billing_address_line_1,
        billing_address_line_2: user.billing_address_line_2,
        contributions_enabled: user.contributions_enabled,
        api_token: user.api_token
    }
  end

  # @return [UserProfileManager]
  def manager
    @manager ||= UserProfileManager.new(@user)
  end

  def load_user!
    @user = current_user.object
  end
end
