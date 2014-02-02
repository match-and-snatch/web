class BaseDecorator

  def self.decorate(object)
    self.class.new(object) if object
  end
end