class BaseDecorator
  attr_reader :object

  def self.decorate(object)
    self.class.new(object) if object
  end
end