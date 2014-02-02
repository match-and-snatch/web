class UserDecorator < BaseDecorator

  # @param object [User]
  def initialize(object)
    @object = object
  end
end