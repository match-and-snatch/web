class SubscriptionsController < ApplicationController
  before_filter :authenticate!, except: [:new, :create, :register]
  before_filter :load_user!

  def new
    template = current_user.authorized? ? 'new' : 'new_unauthorized'
    json_render template
  end

  def index
    @subscriptions = @user.subscriptions
    @subscribed_on_me = Subscription.by_target(@user)
    json_render
  end

  # @todo fix
  def create
    SubscriptionManager.new(current_user.object).subscribe_and_pay_for(@user)
    json_reload
  end

  def register
    SubscriptionManager.new(current_user.object).tap do |manager|
      manager.register_subscribe_and_pay target:       @user,
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

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end
