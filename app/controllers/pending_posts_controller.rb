class PendingPostsController < ApplicationController
  before_action :authenticate!
  before_action :init_profile, only: [:new, :cancel]

  before_action :detect_device_format, only: [:new, :create]

  def new
    respond_to do |format|
      format.json do |variant|
        variant.any { json_replace }
        variant.phone { json_render template: 'new_mobile', format: :html }
      end
    end
  end

  def create
    had_posts = current_user.has_posts?
    @post = create_post
    respond_to do |format|
      format.json do |variant|
        variant.any { had_posts ? json_prepend(html: post_html) : json_replace(html: post_html) }
        variant.phone { json_reload }
      end
    end
  end

  def update
    PostManager.new(user: current_user.object).update_pending(params.slice(%i[message title keywords]))
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
    render_to_string(partial: 'post', locals: {post: @post}, formats: ['html'])
  end

  private

  def init_profile
    @profile = ProfileDecorator.new(current_user.object)
  end
end
