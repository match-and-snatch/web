class PostsController < ApplicationController
  before_filter :authenticate!, except: [:index, :show]
  before_filter :load_user!, only: :index
  before_filter :load_post!, only: [:destroy, :show, :edit, :update, :make_visible, :hide]

  before_action :detect_device_format, only: [:create]

  protect(:index) { can? :see, @user }
  protect(:destroy) { can? :delete, @post }

  def index
    query = Queries::Posts.new(user: @user, current_user: current_user.object, query: params[:q], start_id: params[:last_post_id])
    resp = {last_post_id: query.last_post_id}
    @posts = query.results

    query.user_input? ? json_replace(resp) : json_append(resp)
  end

  def edit
    json_popup
  end

  def show
    if @post.is_a? AudioPost
      respond_to do |wants|
        wants.html do
          error(404)
        end
        wants.xml do
          @uploads = @post.uploads.to_a
          render layout: false
          response.headers['Content-Type'] = 'application/xml; charset=utf-8'
        end
      end
    else
      error(404)
    end
  end

  def update
    PostManager.new(user: current_user.object, post: @post).update(params.slice(:title, :message))
    json_replace html: post_html, notice: :post_updated
  end

  def make_visible
    PostManager.new(user: current_user.object, post: @post).show
    json_replace html: post_html, notice: :post_shown
  end

  def hide
    PostManager.new(user: current_user.object, post: @post).hide
    json_replace html: post_html, notice: :post_hidden
  end

  def create
    has_posts = current_user.has_posts?
    @post = PostManager.new(user: current_user.object).create_status_post(message: params[:message], notify: params.bool(:notify))

    respond_to do |format|
      format.json do |variant|
        variant.phone { json_reload }
        variant.any { has_posts ? json_prepend(notice: :post_created) : json_replace(notice: :post_created) }
      end
    end
  end

  def destroy
    PostManager.new(user: current_user.object).delete(@post)
    json_replace
  end

  private

  def load_post!
    @post = Post.where(id: params[:id]).first or error(404)
  end

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end

  def post_html
    render_to_string(partial: 'post', locals: {post: @post})
  end
end
