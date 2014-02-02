class CurrentUserDecorator < BaseDecorator
  attr_reader :object
  delegate :slug, :email, to: :object

  # @param user [User, nil]
  def initialize(user = nil)
    @object = user || User.new
  end

  def authorized?
    !object.new_record?
  end

  # @return [String]
  def authorization_status_message
    if authorized?
      "Authorized as #{email}"
    else
      'Unauthorized'
    end
  end
end