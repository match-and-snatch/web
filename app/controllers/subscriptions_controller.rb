class SubscriptionsController < ApplicationController
  before_action :authenticate!, except: [:new, :via_register]
  before_action :load_owner!, only: [:new, :create, :via_register, :via_update_cc_data]
  before_action :filter_card_params, only: [:via_register, :via_update_cc_data]
  before_action :load_subscription!, only: [:cancel, :destroy, :enable_notifications, :disable_notifications, :restore, :retry_payment]

  protect(:destroy) { can? :delete, @subscription }

  def new
    template = current_user.authorized? ? 'new' : 'new_unauthorized'
    json_render template: template
  end

  def index
    @subscriptions = current_user.object.subscriptions.active.been_charged.joins(:target_user)
    json_render
  end

  def create
    SubscriptionManager.new(subscriber: current_user.object).subscribe_and_pay_for(@target_user)
    json_reload
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
      session_manager.login(params[:email], params[:password])
    end
    json_reload
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
    json_reload
  end

  def cancel
    json_popup
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
    json_reload
  end

  def restore
    SubscriptionManager.new(subscription: @subscription).restore
    json_reload notice: :restored_subscription
  rescue ManagerError
    json_reload notice: :failed_to_restore_subscription
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
