class WelcomeController < ApplicationController
  before_filter do
    redirect_to profile_path(current_user.object) if current_user.authorized?
  end

  def show
    @welcome = WelcomePresenter.new(current_user.object)
  end
end