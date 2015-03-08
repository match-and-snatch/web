class Api::BaseController < ActionController::Base
  include Concerns::ControllerFramework

  skip_before_filter :verify_authenticity_token

  before_filter :authenticate_by_api_token!

  protected

  def authenticate_by_api_token!
    @current_user = CurrentUserDecorator.new(auth_manager.authenticate_api)
  end

  def auth_manager
    @auth_manager ||= AuthenticationManager.new(api_token: params[:api_token])
  end

  # @return [CurrentUserDecorator]
  def current_user
    @current_user ||= CurrentUserDecorator.new
  end
end