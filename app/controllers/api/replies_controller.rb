class Api::RepliesController < Api::BaseController
  before_action :load_comment!, only: [:create]
  before_action :load_reply!, only: [:update, :make_visible, :hide]

  protect(:create) { can? :comment, @comment.post }
  protect(:update, :make_visible, :hide) { can? :manage, @reply }

  def create
    reply = CommentManager.new(user: current_user.object, post: @comment.post, parent: @comment).create(params.slice(:message, :mentions))
    json_success api_response.comment_data(reply)
  end

  def update
    @reply.update_attributes(params.slice(:message, :mentions))
    json_success api_response.comment_data(@reply)
  end

  def make_visible
    reply = CommentManager.new(user: current_user.object, comment: @reply).show
    json_success api_response.comment_data(reply)
  end

  def hide
    reply = CommentManager.new(user: current_user.object, comment: @reply).hide
    json_success api_response.comment_data(reply)
  end

  private

  def load_reply!
    @reply = Comment.where(id: params[:id]).first or error(404)
  end

  def load_comment!
    @comment = Comment.where(id: params[:comment_id]).first or error(404)
  end
end
