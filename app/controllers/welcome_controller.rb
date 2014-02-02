class WelcomeController < ApplicationController

  def show
    @welcome = WelcomePresenter.new(current_user.object)
  end
end