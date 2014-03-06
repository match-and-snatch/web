class SubscriptionsController < ApplicationController
  before_filter :authenticate!, except: :new
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

  def create
    SubscriptionManager.new(current_user.object).subscribe_to(@user)
    json_reload
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end
