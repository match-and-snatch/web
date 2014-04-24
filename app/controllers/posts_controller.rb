class PostsController < ApplicationController
  before_filter :authenticate!, except: :index
  before_filter :load_user!, only: :index
  before_filter :load_post!, only: [:destroy, :show]

  protect(:index) { can? :see, @user }
  protect(:show) { can? :see, @post.user }
  protect(:destroy) { can? :delete, @post }

  def index
    query = Queries::Posts.new(user: @user, query: params[:q], start_id: params[:last_post_id])
    resp = {last_post_id: query.last_post_id}
    @posts = query.results

    query.user_input? ? json_replace(resp) : json_append(resp)
  end

  def show
    if @post.is_a? AudioPost
      respond_to do |wants|
        wants.html do
          error(404)
        end
        wants.xml do
          @uploads = @post.uploads.to_a
          render :layout => false;
          response.headers["Content-Type"] = "application/xml; charset=utf-8"
        end
      end
    else
      error(404)
    end
  end

  def create
    has_posts = current_user.has_posts?
    @post = PostManager.new(user: current_user.object).create_status_post(message: params[:message])
    has_posts ? json_prepend : json_replace
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
end
