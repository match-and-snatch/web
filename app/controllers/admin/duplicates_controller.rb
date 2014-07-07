class Admin::DuplicatesController < Admin::BaseController

  def index
    @duplicates = DuplicatesPresenter.new
    json_render
  end
end
