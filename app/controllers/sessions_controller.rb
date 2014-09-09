class SessionsController < ApplicationController
  rescue_from(AuthenticationError) { |e| json_fail message: e.message }

  # Logins user
  def create
    reset_session
    user = session_manager.login(params[:email], params[:password], params.bool(:remember_me))

    if user.billing_failed?
      json_redirect account_info_url(anchor: '/account_info/billing_information'), notice: :billing_failed
    else
      json_reload
    end
  end

  # Logs user out
  def logout
    session_manager.logout
    redirect_to root_path
  end
end
