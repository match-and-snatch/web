class SubscribersController < ApplicationController
  before_filter :authenticate!
  before_filter :load_subscriber!, :load_subscription!, only: :destroy

  def index
    @subscribers = current_user.object.subscribers
    json_render
  end

  def destroy
    SubscriptionManager.new(@subscriber).unsubscribe(@subscription)
    json_reload
  end

  private

  def load_subscriber!
    @subscriber = User.where(id: params[:id]).first or error(404)
  end

  def load_subscription!
    @subscription = Subscription.where(target_user_id: current_user.id, user_id: @subscriber.id).first or error(404)
  end
end