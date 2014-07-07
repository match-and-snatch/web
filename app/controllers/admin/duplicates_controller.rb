class Admin::DuplicatesController < Admin::BaseController

  def index
    @duplicates = DuplicatesPresenter.new
  end
end
