class CommentsController < ApplicationController
  before_filter :authenticate!
  before_filter :load_post!, only: [:index, :create]
  before_filter :load_comment!, only: [:edit, :update, :destroy]

  protect(:index, :create) { can? :see, @post }
  protect(:edit, :update, :destroy) { can? :delete, @comment }

  def index
    @query = Queries::Comments.new(post: @post, start_id: params[:last_comment_id])
    json_replace
  end

  def create
    @comment = CommentManager.new(user: current_user.object, post: @post).create(message: params[:message],
                                                                                 mentions: params[:mentions])
    json_render
  end

  def edit
    json_replace
  end

  def update
    @comment.update_attributes(message: params[:message])
    json_replace html: render_to_string(partial: 'comment_row', locals: {comment: @comment})
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