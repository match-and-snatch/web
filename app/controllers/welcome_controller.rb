class WelcomeController < ApplicationController
  before_filter do
    if current_user.authorized?
      if current_user.complete_profile?
        redirect_to profile_path(current_user.object)
      else
        redirect_to account_info_path
      end
    end
  end

  def show
    @random_public_profile = User.random_public_profile
  end
end