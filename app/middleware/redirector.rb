class Redirector

  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.host.starts_with?('www.')
      @app.call env
    else
      [301, {'Location' => request.url.sub('//', '//www.')}, self]
    end
  end

  def each
  end
end
