class Dashboard::Admin::TosVersionsController < Dashboard::Admin::BaseController
  before_action :load_tos_version!, only: [:edit, :update, :show, :publish]

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
    TosManager.new.create(params.slice(:tos, :privacy_policy))
    json_reload
  end

  def edit
    json_popup
  end

  def update
    if params[:commit] == 'Preview'
      @tos_version.attributes = params.slice(:tos, :privacy_policy)
      json_replace partial: 'preview'
    else
      TosManager.new(@tos_version).update(params.slice(:tos, :privacy_policy))
      json_reload
    end
  end

  def show
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
