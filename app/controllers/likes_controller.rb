class LikesController < ApplicationController
  include Concerns::PublicProfileHandler

  before_action :load_likable!
  before_action :load_public_user!
  before_action :authenticate!

  protect { can? :like, @likable }

  def index
    json_render html: @likable.likes.order('likes.created_at DESC').
                                     select('likes.user_id').
                                     includes(:user).
                                     map(&:user).map(&:name).
                                     join(', ').
                                     html_safe
  end

  def create
    LikesManager.new(current_user.object).toggle(@likable)
    json_replace partial: 'like', locals: {post: @likable}
  end

  private

  def load_public_user!
    case @likable
    when Comment
      @target_user = @likable.target_user or error(403)
    when Post
      @target_user = @likable.user
    else
      error(403)
    end
  end

  def load_likable!
    case params[:type]
    when 'comment'
      @likable = Comment.where(id: params[:comment_id]).first
    when 'post'
      @likable = Post.where(id: params[:post_id]).first
    else
      error(403)
    end

    @likable or error(404)
  end
end
