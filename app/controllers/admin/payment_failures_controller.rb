class Admin::PaymentFailuresController < Admin::BaseController

  def index
    @failures = PaymentFailure.includes(:user).preload(:target).order('created_at DESC').page(params[:page]).per(50)
    json_render
  end
end