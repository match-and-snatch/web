class PostsController < ApplicationController
  before_filter :authenticate!
  before_filter :load_user!, only: :index

  def index
    if params[:q].present?
      @posts = Post.where(user_id: @user.id).search_by_message(params[:q])
    else
      @posts = ProfileDecorator.new(@user).recent_posts
    end
    json_replace
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
