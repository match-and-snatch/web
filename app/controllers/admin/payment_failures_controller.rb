class Admin::PaymentFailuresController < Admin::BaseController

  def index
    @failures = PaymentFailure.limit(200).includes(:user).preload(:target).to_a
    json_render
  end
end