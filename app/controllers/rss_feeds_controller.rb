class RssFeedsController < ApplicationController
  before_action :load_user!, only: [:show]
  before_action :request_basic_http_auth!, only: [:index]
  before_action :set_http_content_headers

  def index
    subscription_ids = @current_user.subscriptions.not_removed.where(rejected: false).pluck(:target_user_id)
    @posts = Post.where(user_id: subscription_ids, hidden: false)
                 .order('posts.created_at DESC').limit(50)
    render layout: false, formats: ['atom']
  end

  def show
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
    @current_user = super
  end

  def set_http_content_headers
    headers['Content-Type'] = 'application/xml; charset=utf-8'
  end

  # protected
  #
  # # @return [User] authenticated user
  # def request_basic_http_auth!
  #   viewer = super or return
  #
  #   if @user
  #     viewer = CurrentUserDecorator.new(viewer)
  #     request_http_basic_authentication unless viewer.can?(:see, @user)
  #   end
  # end
end
