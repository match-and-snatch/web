class Admin::ChartsController < Admin::BaseController
  before_filter :initialize_statistics!

  def index
    json_render
  end

  def show
    json_replace
  end

  private

  def initialize_statistics!
    @chart = ChartsPresenter.new(graph_type: params[:id])
  end
end
