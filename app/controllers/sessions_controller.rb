class SessionsController < ApplicationController

  # Shows user login form
  def new
    session_manager.logout
  end

  # Logins user
  def create
    session_manager.login(params[:email], params[:password])
    render json: { status: 'redirect', url: profile_path }
  rescue ManagerError
    render json: { status: 'failed', message: 'email or password is invalid' }
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end