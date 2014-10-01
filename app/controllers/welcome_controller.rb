class WelcomeController < ApplicationController
  before_filter do
    if current_user.authorized?
      if current_user.object.has_profile_page?
        redirect_to profile_path(current_user.object)
      else
        redirect_to account_info_path
      end
    end
  end

  def show
    @show_promo_block = cookies[:boortz_promo_block] != 'false'
  end
end
