class RepliesController < ApplicationController
  include Concerns::PublicProfileHandler

  before_action :authenticate!, except: [:show, :create]
  before_action :load_comment!, only: [:show, :create, :edit, :update]
  before_action :load_reply!, only: [:show, :edit, :update, :make_visible, :hide]

  protect(:create, :show) { can? :comment, @comment.post }
  protect(:edit, :update) { can? :delete, @reply }

  def show
    json_replace partial: 'reply', locals: { reply: @reply }
  end

  def create
    @reply = CommentManager.new(user: current_user.object, post: @comment.post, parent: @comment).
        create(params.slice(:message, :mentions))
    json_render notice: :new_comment
  end

  def edit
    json_replace
  end

  def update
    CommentManager.new(user: current_user.object, comment: @reply).update(params.slice(:message, :mentions))
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
