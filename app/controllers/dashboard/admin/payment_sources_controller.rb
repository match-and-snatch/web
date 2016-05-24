class Dashboard::Admin::PaymentSourcesController < Dashboard::BaseController
  include Dashboard::Concerns::AdminController

  def index
    @payments = Payment.order(created_at: :desc).includes(:subscription, :user, :target_user)

    if params[:source_country].present?
      @payments = @payments.where(source_country: params[:source_country] == 'empty' ? nil : params[:source_country])
    end

    if params[:profile].present?
      join = "INNER JOIN users ON payments.target_user_id = users.id AND users.profile_name ILIKE '%#{params[:profile]}%'"
      @payments = @payments.joins(join)
      @payment_sources = Payment.joins(join).group(:source_country).count
    else
      @payment_sources = Payment.group(:source_country).count
    end

    @payments = @payments.page(params[:page]).per(25)

    json_render
  end
end
