class PostsController < ApplicationController
  before_filter :authenticate!
  before_filter :load_user!, only: :index

  protect(:index) { can? :see, @user }

  def index
    query = Queries::Posts.new(user: @user, query: params[:q], start_id: params[:last_post_id])
    resp = {last_post_id: query.last_post_id}
    @posts = query.results

    query.user_input? ? json_replace(resp) : json_append(resp)
  end

  def create
    has_posts = current_user.has_posts?
    @post = PostManager.new(user: current_user.object).create_status_post(message: params[:message])
    has_posts ? json_prepend : json_replace
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end
