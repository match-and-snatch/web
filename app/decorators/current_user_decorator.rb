class CurrentUserDecorator < BaseDecorator
  attr_reader :object
  delegate :slug, :email, :complete_profile?, to: :object

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
      "Hi, <b>#{object.first_name}</b>!".html_safe
    end
  end
end