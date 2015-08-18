class FeedsController < ApplicationController
  before_action :authenticate!

  # TODO: refactor
  def show
    subscription_user_ids = User.joins(:source_subscriptions).
      where(subscriptions: {user_id: current_user.id}).pluck(:target_user_id)

    @feed_events = FeedEvent.
      where("(feed_events.target_user_id = ? OR
              feed_events.subscription_target_user_id IN (?)) AND
             (feed_events.type <> 'SubscribedFeedEvent' OR feed_events.created_at > ?)".squish,
             current_user.id, subscription_user_ids, 14.days.ago).
      includes(:subscription_target_user, :target_user).
      order('feed_events.created_at DESC')

    if current_user.object.registration_token != "GkTB3tmMC3ivokQWMOXdng" # Wendy
      @feed_events = @feed_events.where("type <> 'UnsubscribedFeedEvent'")
    end

    @feed_events = @feed_events.where("feed_events.type <> 'ContributionFeedEvent'").order('feed_events.created_at DESC').limit(70).to_a

    json_render
  end
end
