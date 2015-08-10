class Api::LikesController < Api::BaseController
  before_action :load_likable!

  protect { can? :like, @likable }

  def create
    like = LikesManager.new(current_user.object).toggle(@likable)
    json_success like_data(like)
  end

  private

  def like_data(like)
    @likable.likers_data.merge(liked: like.persisted?, params[:type] => likable_data)
  end

  def likable_data
    case @likable
    when Comment
      api_response.comment_data(@likable)
    when Post
      api_response.post_data(@likable)
    else
      {}
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
