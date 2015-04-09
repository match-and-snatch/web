class Api::PostsController < Api::BaseController
  before_action :load_user!, only: :index

  protect(:index) { can? :see, @user }

  def index
    query = Queries::Posts.new(user: @user, current_user: current_user.object)
    @posts = query.results.map { |p| post_data(p) }
    json_success @posts
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end

  def post_data(post)
    {
      id: post.id,
      type: post.type,
      title: post.title,
      message: post.message,
      created_at: post.created_at,
      uploads: post_uploads_data(post)
    }
  end

  def post_uploads_data(post)
    post.uploads.map do |upload|
      {
        id: upload.id,
        preview_url: upload.preview_url,
        url: upload.url
      }
    end
  end
end
