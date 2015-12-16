class DuplicatesPresenter
  include Enumerable

  attr_reader :page, :per_page

  def initialize(page: 1, per_page: 15)
    @page = page
    @per_page = per_page
  end

  def collection
    {}
  end

  def each(&block)
    collection.each(&block)
  end
end

