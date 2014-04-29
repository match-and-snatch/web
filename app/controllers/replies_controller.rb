class RepliesController < ApplicationController
  before_filter :authenticate!
  before_filter :load_comment!, only: :create

  protect(:create) { can? :see, @comment.post }

  def create
    @comment = CommentManager.new(user: current_user.object,
                                  post: @comment.post,
                                  parent: @comment).create(params[:message])
    json_render notice: 'Thanks for the comment'
  end

  private

  def load_comment!
    @comment = Comment.where(id: params[:comment_id]).first or error(404)
  end
end