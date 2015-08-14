class Api::SubscriptionsController < Api::BaseController
  before_action :load_owner!, only: [:create, :via_register, :via_update_cc_data]
  before_action :filter_card_params, only: [:via_register, :via_update_cc_data]
  before_action :load_subscription!, only: [:enable_notifications, :disable_notifications, :destroy, :restore]

  protect(:create, :via_update_cc_data) { current_user.authorized? } # TODO (DJ): FIX IT
  protect(:destroy) { can? :delete, @subscription }

  def index
    @subscriptions = current_user.object.subscriptions.accessible.not_expired.joins(:target_user)
    json_success api_response.subscriptions_data(@subscriptions)
  end

  def create
    SubscriptionManager.new(subscriber: current_user.object).subscribe_and_pay_for(@target_user)
    json_success api_response.current_user_data.slice(:subscriptions_count)
  end

  def via_update_cc_data
    SubscriptionManager.new(subscriber: current_user.object).tap do |manager|
      manager.update_cc_subscribe_and_pay target:       @target_user,
                                          number:       params[:number],
                                          cvc:          params[:cvc],
                                          expiry_month: params[:expiry_month],
                                          expiry_year:  params[:expiry_year],
                                          zip:          params[:zip],
                                          city:         params[:city],
                                          address_line_1: params[:address_line_1],
                                          address_line_2: params[:address_line_2],
                                          state:          params[:state]
    end
    json_success api_response.current_user_data.slice(:subscriptions_count, :has_cc_payment_account)
  end

  def via_register
    SubscriptionManager.new(subscriber: current_user.object).tap do |manager|
      manager.register_subscribe_and_pay target:       @target_user,
                                         email:        params[:email],
                                         password:     params[:password],
                                         full_name:    params[:full_name],
                                         number:       params[:number],
                                         cvc:          params[:cvc],
                                         expiry_month: params[:expiry_month],
                                         expiry_year:  params[:expiry_year],
                                         zip:          params[:zip],
                                         city:         params[:city],
                                         address_line_1: params[:address_line_1],
                                         address_line_2: params[:address_line_2],
                                         state:          params[:state]
    end
    json_success
  end

  def enable_notifications
    SubscriptionManager.new(subscription: @subscription).enable_notifications
    json_success
  end

  def disable_notifications
    SubscriptionManager.new(subscription: @subscription).disable_notifications
    json_success
  end

  def destroy
    SubscriptionManager.new(subscription: @subscription).unsubscribe
    notice(:subscription_cancelled, profile_name: @subscription.target_user.profile_name)
    json_success api_response.subscription_data(@subscription)
  end

  def restore
    SubscriptionManager.new(subscription: @subscription).restore
    notice(:restored_subscription)
    json_success api_response.subscription_data(@subscription)
  rescue ManagerError
    json_fail notice(:failed_to_restore_subscription)
  end

  private

  def load_subscription!
    @subscription = Subscription.where(id: params[:id]).first or error(404)
  end

  def load_owner!
    @target_user = User.where(slug: params[:user_id]).first or error(404)
  end

  def filter_card_params
    if params[:expiry_date].present?
      month, year = params[:expiry_date].split(/\s*\/\s*/)
      params[:expiry_month] = month
      params[:expiry_year] = year
    end
  end
end
