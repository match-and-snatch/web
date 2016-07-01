class SubscribersController < ApplicationController
  before_action :authenticate!
  before_action :load_subscriber!, :load_subscription!, only: :destroy

  def index
    @subscribers = current_user.object.subscribers
    json_render
  end

  def destroy
    SubscriptionManager.new(subscriber: @subscriber, subscription: @subscription).unsubscribe
    json_reload notice: "#{@subscriber.name} is no longer subscribed on you."
  end

  private

  def load_subscriber!
    @subscriber = User.where(id: params[:id]).first or error(404)
  end

  def load_subscription!
    @subscription = Subscription.base_scope.where(target_user_id: current_user.id, user_id: @subscriber.id).first or error(404)
  end
end
