class DuplicatesPresenter
  include Enumerable

  def collection
    {}
  end

  def each(&block)
    collection.each(&block)
  end
end

