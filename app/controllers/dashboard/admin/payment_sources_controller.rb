class Dashboard::Admin::PaymentSourcesController < Dashboard::BaseController
  include Dashboard::Concerns::AdminController

  def index
    @payment_sources = Payment.group(:source_country).count
    @payments = Payment.order(created_at: :desc).includes(:subscription, :user, :target_user)

    if params[:source_country].present?
      @payments = @payments.where(source_country: params[:source_country])
    end

    if params[:profile].present?
      @payments = @payments.joins("INNER JOIN users ON payments.target_user_id = users.id AND users.profile_name ILIKE '%#{params[:profile]}%'")
    end

    @payments = @payments.page(params[:page]).per(25)

    json_render
  end
end

