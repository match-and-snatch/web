class PendingPostsController < ApplicationController
  before_filter :authenticate!
  before_filter :init_profile, only: [:new, :cancel]

  def new
    json_replace
  end

  def create
    had_posts = current_user.has_posts?
    @post = create_post
    had_posts ? json_prepend(html: post_html) : json_replace(html: post_html)
  end

  def update
    PostManager.new(user: current_user.object).update_pending(params.slice(%i(message title keywords)))
    json_success
  end

  protected

  def create_post
    raise NotImplementedError
  end

  def media_posts_path
    raise NotImplementedError
  end
  helper_method :media_posts_path

  def post_html
    render_to_string(partial: 'post', locals: {post: @post})
  end

  private

  def init_profile
    @profile = ProfileDecorator.new(current_user.object)
  end
end