class OffersPresenter
  def initialize(user)
    @user = user
  end

  def my
    @my ||= if @user.logged_in?
      @user.offers.order('created_at DESC').limit(10).to_a
    else
     []
    end
  end
end