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
      if remember_me
        @session.permanent[:auth_token] = user.auth_token
      else
        @session[:auth_token] = user.auth_token
      end
    end
  end

  def logout
    @session[:auth_token] = nil
  end

  # @return [CurrentUserDecorator]
  def current_user
    if needs_authorization?
      user = User.where(auth_token: @auth_token).first if @auth_token = @session[:auth_token]
      @current_user = CurrentUserDecorator.new(user)
    end
    @current_user
  end

  private

  def needs_authorization?
    !@current_user || reauthorized?
  end

  def reauthorized?
    @auth_token != @session[:auth_token]
  end
end