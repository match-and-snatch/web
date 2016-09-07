class Dashboard::Admin::TosVersionsController < Dashboard::Admin::BaseController
  before_action :load_tos_version!, only: [:edit, :update, :show, :publish,
                                           :confirm_toggle_acceptance_requirement, :toggle_acceptance_requirement]

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
      manager.update(params.slice(:tos, :privacy_policy))
      json_reload
    end
  end

  def show
    json_popup
  end

  def publish
    manager.publish
    json_reload
  end

  def confirm_toggle_acceptance_requirement
    json_popup
  end

  def toggle_acceptance_requirement
    manager.toggle_acceptance_requirement
    json_reload
  end

  private

  def manager
    TosManager.new(@tos_version)
  end

  def load_tos_version!
    @tos_version = TosVersion.find(params[:id])
  end
end
