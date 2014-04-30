class RepliesController < ApplicationController
  before_filter :authenticate!
  before_filter :load_comment!, only: [:create, :edit, :update]
  before_filter :load_reply!, only: [:edit, :update]

  protect(:create) { can? :see, @comment.post }
  protect(:edit, :update) { can? :delete, @reply }

  def create
    @reply = CommentManager.new(user: current_user.object,
                                post: @comment.post,
                                parent: @comment).create(message: params[:message],
                                                         mentions: params[:mentions])
    json_render notice: 'Thanks for the comment'
  end

  def edit
    json_replace
  end

  def update
    @reply.update_attributes(message: params[:message])
    json_replace html: render_to_string(partial: 'reply', locals: {reply: @reply})
  end

  private

  def load_reply!
    @reply = Comment.where(id: params[:id]).first or error(404)
  end

  def load_comment!
    @comment = Comment.where(id: params[:comment_id]).first or error(404)
  end
end