class FeedsController < ApplicationController
  before_action :authenticate!

  # TODO: refactor
  def show
    subscription_user_ids = User.joins(:source_subscriptions).where(subscriptions: {user_id: current_user.id}).pluck(:target_user_id)

    sql = <<-SQL.squish
      feed_events.hidden = ? AND (feed_events.target_user_id = ? OR feed_events.subscription_target_user_id IN (?)) AND (feed_events.type <> 'SubscribedFeedEvent' OR feed_events.created_at > ?)
    SQL

    @feed_events = FeedEvent.where(sql, false, current_user.id, subscription_user_ids, 14.days.ago).includes(:subscription_target_user, :target_user).order(created_at: :desc)

    if current_user.object.registration_token != "GkTB3tmMC3ivokQWMOXdng" # Wendy
      @feed_events = @feed_events.where.not(type: 'UnsubscribedFeedEvent')
    end

    @feed_events = @feed_events.where.not(type: 'ContributionFeedEvent').order(created_at: :desc).limit(70).to_a

    json_render
  end
end
