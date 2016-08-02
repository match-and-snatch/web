class Dashboard::Admin::TosVersionsController < Dashboard::Admin::BaseController
  before_action :load_tos_version!, only: [:text, :publish]

  def index
    @tos_versions = TosVersion
      .order(published_at: :desc, created_at: :desc)
      .page(params[:page]).per(100)
    json_render
  end

  def new
    json_popup
  end

  def create
    TosManager.new.create(tos: params[:tos])
    json_reload
  end

  def text
    json_popup
  end

  def publish
    TosManager.new(@tos_version).publish
    json_reload
  end

  private

  def load_tos_version!
    @tos_version = TosVersion.find(params[:id])
  end
end
