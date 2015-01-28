class RssFeedsController < ApplicationController
  before_filter :load_user!
  before_filter :request_basic_http_auth!

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

  def request_basic_http_auth!
    viewer = authenticate_with_http_basic do |u, p|
      begin
        session_manager.login(u, p)
      rescue ManagerError
      end
    end

    unless viewer
      return request_http_basic_authentication
    end

    viewer = CurrentUserDecorator.new(viewer)

    unless viewer.can?(:see, @user)
      request_http_basic_authentication
    end
  end
end