class WelcomeController < ApplicationController
  before_filter do
    if current_user.authorized?
      if current_user.has_complete_profile?
        redirect_to profile_path(current_user.object)
      else
        redirect_to account_info_path
      end
    end
  end

  def show
    @welcome = WelcomePresenter.new(current_user.object)
  end
end