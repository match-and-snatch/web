class Api::PostsController < Api::BaseController
  before_action :load_user!, only: :index

  protect(:index) { can? :see, @user }

  def index
    query = Queries::Posts.new(user: @user, current_user: current_user.object, query: params[:q], start_id: params[:last_post_id])
    @posts = query.results.map { |p| post_data(p) }
    json_success posts: @posts, last_post_id: query.last_post_id
  end

  def feed
    @posts = Post.select('posts.*, COUNT(likes.id) as likes_count')
                 .joins(user: :source_subscriptions)
                 .joins(:likes)
                 .where(subscriptions: {user_id: current_user.id})
                 .group('posts.id')
                 .order('posts.created_at DESC')
                 .includes(:uploads)
                 .limit(100)
    @posts = @posts.map { |p| post_data(p).merge(likes_count: p.likes_count) }
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
      },
      likes: post.likers_data.merge(liked: current_user.likes?(post))
    }
  end

  def post_uploads_data(post)
    post.uploads.map do |upload|
      common_data = {
        id: upload.id,
        file_url: upload.rtmp_path,
        preview_url: upload.preview_url,
        original_url: upload.original_url
      }
      video_data = if upload.video?
                     playlist_url = if upload.low_quality_playlist_url
                                       playlist_video_path(upload.id, format: 'm3u8')
                                     end
                     {
                       hdfile_url:   upload.hd_rtmp_path,
                       playlist_url: playlist_url
                     }
                   else
                     {}
                   end
      common_data.merge(video_data)
    end
  end
end
