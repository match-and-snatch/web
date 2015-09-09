class Admin::DuplicatesController < Admin::BaseController

  def index
    @duplicates = UsersDuplicatesPresenter.new
    @card_duplicates = CardsDuplicatesPresenter.new
    json_render
  end
end
