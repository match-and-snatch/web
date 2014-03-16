class PostsController < ApplicationController
  before_filter :authenticate!
  before_filter :load_user!, only: :index

  def index
    if params[:q].present?
      @posts = Post.where(user_id: @user.id).search_by_message(params[:q]).limit(10)
    else
      @posts = ProfileDecorator.new(@user).recent_posts
    end

    if params[:last_post_id].present?
      @posts = @posts.where(['id < ?', params[:last_post_id]])
      return json_append last_post_id: @posts.last.try(:id)
    else
      if params[:q]
        return json_replace last_post_id: @posts.last.try(:id)
      else
        return json_append last_post_id: @posts.last.try(:id)
      end
    end
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
