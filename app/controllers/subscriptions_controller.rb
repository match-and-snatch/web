class SubscriptionsController < ApplicationController
  before_filter :authenticate!, except: :new
  before_filter :load_user!

  def new
    template = current_user.authorized? ? 'new' : 'new_unauthorized'
    json_render template
  end

  def index
    @subscriptions = @user.subscriptions
    @subscribed_on_me = Subscription.by_target(@user)
    json_render
  end

  def create
    if params['cc_data']
      UserProfileManager.new(current_user.object).update_cc_data number:       params['cc_data']['number'],
                                                                 cvc:          params['cc_data']['cvc'],
                                                                 expiry_month: params['cc_data']['expiry_month'],
                                                                 expiry_year:  params['cc_data']['expiry_year']
    end
    SubscriptionManager.new(current_user.object).subscribe_and_pay_for(@user)
    json_reload
  end

  private

  def load_user!
    @user = User.where(slug: params[:user_id]).first or error(404)
  end
end
