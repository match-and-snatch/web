class SessionManager < BaseManager

  # @param session [Hash]
  def initialize(session)
    @session = session
  end

  # @param user [User]
  def login(user)
    @session[:user_id] = user.id
  end

  def logout
    @session[:user_id] = nil
  end

  # @return [CurrentUserDecorator]
  def current_user
    if needs_authorization?
      @user_id = @session[:user_id]
      @current_user = CurrentUserDecorator.new(@user_id and User.where(id: @user_id).first)
    else
      @current_user
    end
  end

  private

  def needs_authorization?
    !@current_user || reauthorized?
  end

  def reauthorized?
    @user_id != @session[:user_id]
  end
end