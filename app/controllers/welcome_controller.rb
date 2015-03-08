class WelcomeController < ApplicationController
  before_action do
    if current_user.authorized?
      if current_user.object.has_profile_page?
        redirect_to profile_path(current_user.object)
      else
        if mobile_phone_device?
          new_way = profile_path(current_user.last_visited_profile) if current_user.last_visited_profile.try(:has_profile_page?)
        end

        redirect_to(new_way || account_info_path)
      end
    end
  end

  def show
    @show_promo_block = cookies[:boortz_promo_block] != 'hidden'
  end
end
