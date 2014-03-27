class Owner::ThirdStepsController < Owner::BaseController

  def show
    json_replace
  end

  def update
    UserProfileManager.new(@user).update_payment_information holder_name:    params[:holder_name],
                                                             routing_number: params[:routing_number],
                                                             account_number: params[:account_number]
    json_redirect profile_path(@user)
  end
end