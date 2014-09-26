class WelcomeController < ApplicationController
  before_filter do
    if current_user.authorized?
      if current_user.object.has_profile_page?
        redirect_to profile_path(current_user.object)
      else
        new_way = account_info_path
        if mobile_phone_device?
          new_way = profile_path(current_user.last_visited_profile) if current_user.last_visited_profile
        end
        redirect_to new_way
      end
    end
  end

  def show
    @show_promo_block = cookies[:boortz_promo_block] != 'hidden'
  end
end
