class SubscriptionsController < ApplicationController
  before_filter :authenticate!, except: [:new, :via_register]
  before_filter :load_owner!, only: [:new, :create, :via_register, :via_update_cc_data]
  before_filter :load_subscription!, only: [:cancel, :destroy, :enable_notifications, :disable_notifications, :restore, :retry_payment]

  protect(:destroy) { can? :delete, @subscription }

  def new
    template = current_user.authorized? ? 'new' : 'new_unauthorized'
    json_render template: template
  end

  def index
    @subscriptions = current_user.object.subscriptions
    json_render
  end

  def create
    SubscriptionManager.new(current_user.object).subscribe_and_pay_for(@owner)
    json_reload
  end

  def via_register
    SubscriptionManager.new(current_user.object).tap do |manager|
      manager.register_subscribe_and_pay target:       @owner,
                                         email:        params[:email],
                                         password:     params[:password],
                                         full_name:    params[:full_name],
                                         number:       params[:number],
                                         cvc:          params[:cvc],
                                         expiry_month: params[:expiry_month],
                                         expiry_year:  params[:expiry_year]
      session_manager.login(params[:email], params[:password])
    end
    json_reload
  end

  def via_update_cc_data
    SubscriptionManager.new(current_user.object).tap do |manager|
      manager.update_cc_subscribe_and_pay target:       @owner,
                                          number:       params[:number],
                                          cvc:          params[:cvc],
                                          expiry_month: params[:expiry_month],
                                          expiry_year:  params[:expiry_year]
    end
    json_reload
  end

  def cancel
    json_popup
  end

  def enable_notifications
    SubscriptionManager.new(current_user.object).enable_notifications(@subscription)
    json_success
  end

  def disable_notifications
    SubscriptionManager.new(current_user.object).disable_notifications(@subscription)
    json_success
  end

  def destroy
    SubscriptionManager.new(current_user.object).unsubscribe(@subscription)
    notice(:unsubscribed)
    json_reload
  end

  def restore
    SubscriptionManager.new(current_user.object).restore(@subscription)
    json_reload notice: :restored_subscription
  rescue ManagerError
    json_reload notice: :failed_to_restore_subscription
  end

  def retry_payment
    PaymentManager.new.pay_for(@subscription)
    json_reload notice: :restored_subscription
  rescue ManagerError
    json_reload notice: :failed_to_restore_subscription
  end

  private

  def load_subscription!
    @subscription = Subscription.where(id: params[:id]).first or error(404)
  end

  def load_owner!
    @owner = User.where(slug: params[:user_id]).first or error(404)
  end
end
