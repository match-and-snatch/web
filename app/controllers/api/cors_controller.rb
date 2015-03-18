class Api::CorsController < Api::BaseController
  skip_before_action :authenticate_by_api_token

  def preflight
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = request.headers['Access-Control-Request-Headers']
    headers['Access-Control-Max-Age'] = '1728000'

    render text: '', content_type: 'text/plain'
  end
end
