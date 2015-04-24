class Api::SubscriptionsController < Api::BaseController
  before_action :load_owner!, only: [:create, :via_update_cc_data]
  before_action :filter_card_params, only: [:via_register, :via_update_cc_data]

  protect(:create) { current_user.authorized? } # TODO (DJ): FIX IT
  
  def create
    SubscriptionManager.new(subscriber: current_user.object).subscribe_and_pay_for(@target_user)
    json_success
  end

  def via_update_cc_data
    SubscriptionManager.new(subscriber: current_user.object).tap do |manager|
      manager.update_cc_subscribe_and_pay target:       @target_user,
                                          number:       params[:number],
                                          cvc:          params[:cvc],
                                          expiry_month: params[:expiry_month],
                                          expiry_year:  params[:expiry_year],
                                          zip:          params[:zip],
                                          city:         params[:city],
                                          address_line_1: params[:address_line_1],
                                          address_line_2: params[:address_line_2],
                                          state:          params[:state]
    end
    json_success
  end

  def via_register
    SubscriptionManager.new(subscriber: current_user.object).tap do |manager|
      manager.register_subscribe_and_pay target:       @target_user,
                                         email:        params[:email],
                                         password:     params[:password],
                                         full_name:    params[:full_name],
                                         number:       params[:number],
                                         cvc:          params[:cvc],
                                         expiry_month: params[:expiry_month],
                                         expiry_year:  params[:expiry_year],
                                         zip:          params[:zip],
                                         city:         params[:city],
                                         address_line_1: params[:address_line_1],
                                         address_line_2: params[:address_line_2],
                                         state:          params[:state]
      session_manager.login(params[:email], params[:password])
    end
    json_success
  end

  private

  def load_owner!
    @target_user = User.where(slug: params[:user_id]).first or error(404)
  end

  def filter_card_params
    if params[:expiry_date].present?
      month, year = params[:expiry_date].split(/\s*\/\s*/)
      params[:expiry_month] = month
      params[:expiry_year] = year
    end
  end
end
