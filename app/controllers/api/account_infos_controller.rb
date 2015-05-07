class Api::AccountInfosController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :authenticate_by_api_token!, :load_user!

  protect(%i[settings update_account_picture update_general_information update_cc_data
update_bank_account_data enable_rss disable_rss enable_downloads disable_downloads
enable_itunes disable_itunes]) do
    current_user == @user
  end

  def settings
    respond_with_user_data
  end

  def update_account_picture
    manager.update_account_picture(params[:transloadit])
    respond_with_user_data
  end

  def update_general_information
    manager.update_general_information(params.slice(:full_name, :email))
    respond_with_user_data
  end

  def update_cc_data
    manager.update_cc_data(params.slice(:number, :cvc, :expiry_month, :expiry_year, :zip, :city, :state, :address_line_1, :address_line_2))
    respond_with_user_data
  end

  def update_bank_account_data
    manager.update_payment_information(params.slice(:holder_name, :routing_number, :account_number))
    respond_with_user_data
  end

  def enable_rss
    manager.enable_rss
    respond_with_user_data
  end

  def disable_rss
    manager.disable_rss
    respond_with_user_data
  end

  def enable_downloads
    manager.enable_downloads
    respond_with_user_data
  end

  def disable_downloads
    manager.disable_downloads
    respond_with_user_data
  end

  def enable_itunes
    manager.enable_itunes
    respond_with_user_data
  end

  def disable_itunes
    manager.disable_itunes
    respond_with_user_data
  end

  private

  def respond_with_user_data
    json_success(user_data(@user))
  end

  def user_data(user)
    {
      slug: user.slug,
      is_profile_owner: user.is_profile_owner?,
      cost: user.cost,
      account_info: {
        full_name: user.full_name,
        email: user.email,
        account_picture_url: user.account_picture_url
      },
      billing_info: {
        address_line_1: user.billing_address_line_1,
        address_line_2: user.billing_address_line_2,
        city: user.billing_address_city,
        state: user.billing_address_state,
        zip: user.billing_address_zip,
        last_four_cc_numbers: user.last_four_cc_numbers
      },
      payout_info: {
        holder_name: user.holder_name,
        routing_number: user.routing_number,
        account_number: user.account_number
      },
      display_settings: {
        itunes_enabled: user.itunes_enabled,
        rss_enabled: user.rss_enabled,
        downloads_enabled: user.downloads_enabled
      },
      profile_info: {
        profile_name: user.profile_name,
        vacation_enabled: user.vacation_enabled
      },
      benefits: user.benefits.order(:ordering).pluck(:message)
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
