class Dashboard::Admin::StaticPagesController < Dashboard::Admin::BaseController
  include Concerns::Failable

  before_action :load_static_page!, only: %i[show edit update destroy]

  def index
    @static_pages = StaticPage.order(created_at: :desc).all
    json_render
  end

  def new
    json_popup
  end

  def create
    @static_page = StaticPage.new(params.permit(:slug, :content))
    save_or_die! @static_page
    json_reload notice: 'The page has been created'
  end

  def edit
    json_popup
  end

  def update
    @static_page.attributes = params.permit(:slug, :content)
    save_or_die! @static_page
    json_reload notice: 'The page has been updated'
  end

  def destroy
    @static_page.destroy!
    json_reload notice: 'The page has been removed'
  end

  private

  def load_static_page!
    @static_page = StaticPage.find(params[:id])
  end
end
