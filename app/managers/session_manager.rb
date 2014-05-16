class SessionManager < BaseManager

  # @param session [Hash]
  def initialize(session)
    @session = session
  end

  # @param email [String]
  # @param password [String]
  # @param remember_me [true, false, nil]
  # @return [User, nil]
  def login(email, password, remember_me = false)
    AuthenticationManager.new(email: email, password: password).authenticate.tap do |user|
      if remember_me == '1'
        @session.permanent[:auth_token] = user.auth_token
      else
        @session[:auth_token] = user.auth_token
      end
    end
  end

  # @param admin [User]
  # @param user [User]
  def login_as(admin, user)
    raise 'Pizdec' unless admin.admin?

    @session[:auth_token] = user.auth_token
    @session[:admin_token] = admin.auth_token
  end

  def logout
    @session[:auth_token] = nil
    if @session[:admin_token]
      @session[:auth_token] = @session[:admin_token]
    end
    @session[:admin_token] = nil
  end

  # @return [CurrentUserDecorator]
  def current_user
    if needs_authorization?
      user = User.where(auth_token: @auth_token).first if @auth_token = @session['auth_token']

      if user && !user.activated?
        if User.by_email(user.email).where(activated: true).any?
          logout
          fail_with! 'Your session is invalid'
        end
      end
      @current_user = CurrentUserDecorator.new(user)
    end
    @current_user
  end

  private

  def needs_authorization?
    !@current_user || reauthorized?
  end

  def reauthorized?
    @auth_token != @session['auth_token']
  end
end