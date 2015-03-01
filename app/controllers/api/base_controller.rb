class Api::BaseController < ActionController::Base
  include Concerns::ControllerFramework

  skip_before_filter :verify_authenticity_token
end