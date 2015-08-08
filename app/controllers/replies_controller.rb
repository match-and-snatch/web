class RepliesController < ApplicationController
  include Concerns::PublicProfileHandler

  before_action :authenticate!, except: [:create]
  before_action :load_comment!, only: [:create, :edit, :update]
  before_action :load_reply!, only: [:edit, :update, :make_visible, :hide]

  protect(:create) { can? :comment, @comment.post }
  protect(:edit, :update) { can? :delete, @reply }

  def create
    comment_flow.create(new_comment_params).pass do |reply|
      @reply = reply
      json_render notice: :new_comment
    end
  end

  def edit
    json_replace
  end

  def update
    comment_flow.update(params.slice(:message)).pass { render_comment_row }
  end

  def make_visible
    comment_flow.show.pass { render_comment_row }
  end

  def hide
    comment_flow.hide.pass { render_comment_row }
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

  def render_comment_row
    json_replace html: reply_html
  end

  def comment_flow
    @comment_flow ||= CommentFlow.init(self, subject: @reply)
  end

  def new_comment_params
    params.slice(:message, :mentions).merge(parent: @comment)
  end
end
