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
    layout.promo_block_hidden = cookies[:promo_block_hidden]
  end
end