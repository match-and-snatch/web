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
    @post = PostManager.new(user: current_user.object).create(params[:message])
    json_render
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end
