class CommentsController < ApplicationController
  before_filter :authenticate!
  before_filter :load_post!, only: [:index, :create]
  before_filter :load_comment!, only: :destroy

  protect(:index, :create) { can? :see, @post }
  protect(:destroy) { can? :delete, @comment }

  def index
    @comments = @post.comments
    json_render
  end

  def create
    @comment = CommentManager.new(user: current_user.object, post: @post).create(params[:message])
    json_render
  end

  def destroy
    @comment.destroy
    json_replace
  end

  private

  def load_comment!
    @comment = Comment.where(id: params[:id]).first or error(404)
  end

  def load_post!
    @post = Post.where(id: params[:post_id]).first or error(404)
  end
end