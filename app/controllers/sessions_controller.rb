class SessionsController < ApplicationController
  popup :new do
    layout[:title] = 'Login'
  end

  def create
    pass_flow(flow.login(params[:email], params[:password])) do
      login flow.user
      json_reload
    end
  end

  def destroy
    logout
    json_redirect '/', notice: 'Successfully logged out'
  end

  private

  def flow
    @flow ||= UserFlow.new
  end
end