class Admin::PaymentFailuresController < Admin::BaseController

  def index
    @failures = PaymentFailure.limit(200).includes(:user).preload(:target).order('created_at DESC').to_a
    json_render
  end
end