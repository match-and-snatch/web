class WelcomeController < ApplicationController

  def show
    @offers = OffersPresenter.new(current_user)
  end
end