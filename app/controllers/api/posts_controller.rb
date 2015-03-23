class Api::PostsController < Api::BaseController
  before_action :load_user!, only: :index

  protect(:index) { can? :see, @user }

  def index
    query = Queries::Posts.new(user: @user, current_user: current_user.object, query: params[:q], start_id: params[:last_post_id])
    @posts = query.results.map { |p| post_data(p) }
    json_success posts: @posts, last_post_id: query.last_post_id
  end

  def feed
    @posts = Post.joins(user: :source_subscriptions).where(subscriptions: {user_id: current_user.id})
                 .includes(:uploads)
    @posts = @posts.map { |p| post_data(p) }
    json_success posts: @posts
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
      uploads: post_uploads_data(post),
      user: {
        id: post.user.id,
        small_profile_picture_url: post.user.small_profile_picture_url
      }
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
