class Api::AccountInfosController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :load_user!

  protect(:settings, :billing_information, :update_account_picture, :update_general_information,
          :update_cc_data) { current_user.authorized? }

  def settings
    respond_with_settings_data
  end

  def billing_information
    @subscriptions = SubscriptionsPresenter.new(user: @user)
    @contributions = Contribution.where(user_id: @user.id, recurring: true).limit(200)
    json_success billing_information_data(subscriptions: @subscriptions, contributions: @contributions)
  end

  def update_account_picture
    manager.update_account_picture(params[:transloadit])
    respond_with_settings_data
  end

  def update_general_information
    manager.update_general_information(params.slice(:full_name, :email))
    respond_with_settings_data
  end

  def update_cc_data
    manager.update_cc_data(params.slice(:number, :cvc, :expiry_month, :expiry_year, :zip, :city, :state, :address_line_1, :address_line_2))
    respond_with_settings_data
  end

  private

  def respond_with_settings_data
    json_success settings_data(@user)
  end

  def billing_information_data(subscriptions: [], contributions: [])
    {
      subscriptions: {
        show_failed_column: subscriptions.show_failed_column?,
        active: subscriptions.active.map do |subscription|
          {
            id: subscription.id,
            billing_date: subscription.billing_date.to_s(:long),
            target_user: target_user_data(subscription.target_user)
          }
        end,
        canceled: subscriptions.canceled.map do |subscription|
          {
            id: subscription.id,
            canceled_at: subscription.canceled_at.to_s(:long),
            removed: subscription.removed?,
            rejected: subscription.rejected?,
            target_user: target_user_data(subscription.target_user)
          }
        end
      },
      contributions: contributions.map do |contribution|
        {
          id: contribution.id,
          target_user: target_user_data(contribution.target_user),
          next_billing_date: contribution.next_billing_date.to_s(:long)
        }
      end
    }
  end

  def target_user_data(user)
    {
      id: user.id,
      slug: user.slug,
      name: user.name,
      is_profile_owner: user.is_profile_owner?,
      vacation_enabled: user.vacation_enabled?
    }
  end

  def settings_data(user)
    {
      slug: user.slug,
      is_profile_owner: user.is_profile_owner?,
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
      }
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
