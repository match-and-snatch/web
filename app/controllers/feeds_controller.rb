class FeedsController < ApplicationController
  before_action :authenticate!

  # TODO: refactor
  def show
    subscription_user_ids = User.joins(:source_subscriptions).
      where(subscriptions: {user_id: current_user.id}).pluck(:target_user_id)
    @feed_events = FeedEvent.
      where('target_user_id = ? OR subscription_target_user_id IN (?)', current_user.id, subscription_user_ids).
      order('feed_events.created_at DESC').limit(70).to_a

    json_render
  end
end
