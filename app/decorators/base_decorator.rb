class BaseDecorator
  attr_reader :object

  def self.decorate(object)
    self.new(object)
  end

  def self.decorate_collection(collection)
    CollectionDecorator.new(collection, self)
  end

  class CollectionDecorator
    include Enumerable
    delegate :current_page, :total_pages, :limit_value, to: :source

    attr_reader :source

    # @param source [Enumerable]
    # @param decorator_class [Class]
    def initialize(source, decorator_class)
      @source = source
      @decorator_class = decorator_class
    end

    def each(&block)
      source.each do |x|
        block.call(@decorator_class.decorate(x))
      end
    end
  end
end