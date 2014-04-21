class Redirector

  def initialize(app)
    @app = app
  end

  def call(env)
    if env['HTTP_HOST'] != 'www.connectpal.com'
      [301, { 'Location' => 'https://www.connectpal.com' }, ['Redirecting you to the main domain...']]
    else
      @app.call env
    end
  end
end