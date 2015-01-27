class RepliesController < ApplicationController
  include Concerns::PublicProfileHandler

  before_filter :authenticate!, except: [:create]
  before_filter :load_comment!, only: [:create, :edit, :update]
  before_filter :load_reply!, only: [:edit, :update, :make_visible, :hide]

  protect(:create) { can? :comment, @comment.post }
  protect(:edit, :update) { can? :delete, @reply }

  def create
    @reply = CommentManager.new(user: current_user.object, post: @comment.post, parent: @comment).
      create(params.slice(:message, :mentions))
    json_render notice: :new_comment
  end

  def edit
    json_replace
  end

  def update
    @reply.update_attributes(message: params[:message])
    json_replace html: reply_html
  end

  def make_visible
    CommentManager.new(user: current_user.object, comment: @reply).show
    json_replace html: reply_html
  end

  def hide
    CommentManager.new(user: current_user.object, comment: @reply).hide
    json_replace html: reply_html
  end

  protected

  # @overload
  def load_public_user!
    @target_user ||= @comment.try(:post_user) || @post.try(:user)
  end

  private

  def load_reply!
    @reply = Comment.where(id: params[:id]).first or error(404)
  end

  def load_comment!
    @comment = Comment.where(id: params[:comment_id]).first or error(404)
  end

  def reply_html
    render_to_string(partial: 'reply', locals: {reply: @reply})
  end
end
