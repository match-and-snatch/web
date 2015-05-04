class Api::PostsController < Api::BaseController
  before_action :load_user!, only: :index
  before_action :load_post!, only: [:show, :update, :destroy, :destroy_upload]

  protect(:index) { can? :see, @user }
  protect(:show) { can? :see, @post }
  protect(:destroy) { can? :delete, @post }
  protect(:destroy_upload) { can? :manage, @post }

  def index
    query = Queries::Posts.new(user: @user, current_user: current_user.object, query: params[:q], start_id: params[:last_post_id])
    @posts = query.results.map { |p| post_data(p) }
    json_success posts: @posts, last_post_id: query.last_post_id
  end

  def show
    json_success post_data(@post)
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

  def update
    post = manager(post: @post).update params.slice(:title, :message)
    json_success post_data(post)
  end

  def destroy
    manager.delete(@post)
    json_success
  end

  def destroy_upload
    @upload = @post.uploads.find(params[:upload_id])
    post = UploadManager.new(current_user.object).remove_upload(upload: @upload)
    json_success post_data(post)
  end

  private

  def manager(post: nil)
    PostManager.new(user: current_user.object, post: post)
  end

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end

  def load_post!
    @post = Post.where(id: params[:id]).first or error(404)
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
        filename: upload.filename,
        file_url: upload.rtmp_path,
        preview_url: upload.preview_url,
        original_url: upload.original_url
      }
      video_data = if upload.video?
                     playlist_url = if upload.low_quality_playlist_url
                                       playlist_video_url(upload.id, format: 'm3u8')
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
