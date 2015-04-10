class FeedsController < ApplicationController
  before_action :authenticate!

  # TODO: refactor
  def show
    subscription_user_ids = User.joins(:source_subscriptions).
      where(subscriptions: {user_id: current_user.id}).pluck(:target_user_id)

    @feed_events = FeedEvent.
      where('target_user_id = ? OR subscription_target_user_id IN (?)', current_user.id, subscription_user_ids).
      order('feed_events.created_at DESC')

    if current_user.object.registration_token != "GkTB3tmMC3ivokQWMOXdng" # Wendy
      @feed_events = @feed_events.where("type <> 'UnsubscribedFeedEvent'")
    end

    @feed_events = @feed_events.order('feed_events.created_at DESC').limit(70).to_a

    json_render
  end
end
