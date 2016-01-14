class CommentsController < ApplicationController
  include Concerns::PublicProfileHandler

  before_action :authenticate!, except: [:show, :create]
  before_action :load_post!, only: [:index, :create]
  before_action :load_comment!, only: [:edit, :update, :destroy, :make_visible, :hide, :like, :show]

  protect(:index, :create, :like, :show, :full_text) { can? :comment, post }
  protect(:edit, :update, :make_visible, :hide, :destroy) { can? :manage, @comment }

  def index
    @query = Queries::Comments.new(post: @post, start_id: params[:last_comment_id])
    json_replace
  end

  def show
    json_replace partial: 'comment_row', locals: { comment: @comment }
  end

  def create
    comment_flow.create(new_comment_params).pass do |comment|
      @comment = comment
      json_render
    end
  end

  def edit
    json_replace
  end

  def update
    comment_flow.update(params.slice(:message)).pass { render_comment_row }
  end

  def full_text
    json_replace
  end

  def make_visible
    comment_flow.show.pass { render_comment_row }
  end

  def hide
    comment_flow.hide.pass { render_comment_row }
  end

  def destroy
    comment_flow.remove.pass { json_replace }
  end

  def like
    comment_flow.toggle_like.pass do
      json_replace partial: 'like_small', locals: {comment: @comment}
    end
  end

  protected

  # @overload
  def load_public_user!
    @target_user ||= @comment.try(:post_user) || @post.try(:user)
  end

  private

  def post
    @post || comment.post
  end

  def comment
    @comment || load_comment!
  end

  def load_comment!
    @comment = Comment.where(id: params[:id]).first or error(404)
  end

  def load_post!
    @post = Post.where(id: params[:post_id]).first or error(404)
  end

  def render_comment_row
    json_replace partial: 'comment_row', locals: {comment: @comment}
  end

  def comment_flow
    @comment_flow ||= CommentFlow.init(self, subject: @comment)
  end

  def new_comment_params
    params.slice(:message, :mentions).merge(post: @post)
  end
end

