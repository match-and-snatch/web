class RssFeedsController < ApplicationController
  before_filter :load_user!

  def show
    headers['Content-Type'] = 'application/xml; charset=utf-8'
    @feed_events = FeedEvent.where(subscription_target_user_id: @user.id).
      order('feed_events.created_at DESC').limit(70).to_a

    respond_to do |format|
      format.atom { render layout: false }
      format.rss { render layout: false }
    end
  end

  private

  def load_user!
    @user = User.where(id: params[:user_id], rss_enabled: true).first or error(404)
  end
end