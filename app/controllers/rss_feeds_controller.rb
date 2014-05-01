class RssFeedsController < ApplicationController
  before_filter :load_user!

  def show
    respond_to do |format|
      format.atom do
        @feed_events = FeedEvent.where(subscription_target_user_id: @user.id).order('feed_events.created_at DESC').limit(70).to_a
        render layout: false
      end
      format.rss { redirect_to user_rss_feed_path(@user.id, format: :atom), status: :moved_permanently }
    end
  end

  private

  def load_user!
    @user = User.where(id: params[:user_id]).first or error(404)
  end
end