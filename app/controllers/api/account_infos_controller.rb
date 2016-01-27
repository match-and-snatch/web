class Api::AccountInfosController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :load_user!

  protect(:settings, :billing_information, :update_account_picture, :change_password,
          :update_general_information, :update_cc_data, :delete_cc_data) { current_user.authorized? }

  def settings
    respond_with_account_data
  end

  def billing_information
    @subscriptions = SubscriptionsPresenter.new(user: @user)
    @contributions = @user.contributions.recurring.limit(200)
    json_success api_response.billing_information_data(subscriptions: @subscriptions, contributions: @contributions)
  end

  def update_account_picture
    manager.update_account_picture(params[:transloadit])
    respond_with_account_data
  end

  def delete_account_picture
    manager.delete_account_picture
    json_success
  end

  def change_password
    manager.change_password(params.slice(:current_password, :new_password, :new_password_confirmation))
    notice :updated_password
    json_success
  end

  def update_general_information
    manager.update_general_information(params.slice(:full_name, :email))
    respond_with_account_data
  end

  def update_cc_data
    manager.pull_cc_data(params.slice(:stripe_token, :expiry_month, :expiry_year, :zip, :city, :state, :address_line_1, :address_line_2))
    respond_with_account_data
  end

  def delete_cc_data
    manager.delete_cc_data!
    notice :removed_cc_data
    respond_with_account_data
  end

  private

  def respond_with_account_data
    json_success api_response.account_data(@user)
  end

  # @return [UserProfileManager]
  def manager
    @manager ||= UserProfileManager.new(@user)
  end

  def load_user!
    @user = current_user.object
  end
end
