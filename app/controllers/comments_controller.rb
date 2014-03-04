class CommentsController < ApplicationController
  before_filter :authenticate!
  before_filter :load_post!

  def index
    @comments = @post.comments
    json_render
  end

  def create
    @comment = CommentManager.new(user: current_user.object, post: @post).create(params[:message])
    json_render
  end

  private

  def load_post!
    @post = Post.where(id: params[:post_id]).first or error(404)
  end
end