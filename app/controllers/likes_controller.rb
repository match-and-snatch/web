class LikesController < ApplicationController
  include Concerns::PublicProfileHandler

  before_filter :authenticate!
  before_filter :load_likable!

  def index
    json_render html: @likable.likes.order('likes.created_at DESC').
                                     select('likes.user_id').
                                     includes(:user).
                                     map(&:user).map(&:name).
                                     join('<br/>').
                                     html_safe
  end

  def create
    LikesManager.new(current_user.object).toggle(@likable)
    json_replace partial: 'like', locals: {post: @likable}
  end

  private

  def load_likable!
    case params[:type]
    when 'comment'
      @likable = Comment.where(id: params[:comment_id]).first
    when 'post'
      @likable = Post.where(id: params[:post_id]).first
    end

    @likable or error(404)
  end
end
