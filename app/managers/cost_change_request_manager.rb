class CostChangeRequestManager < BaseManager
  attr_reader :user, :request

  def initialize(user: nil, request: nil)
    @request = request
    @user = user || request.user
  end

  def create(new_cost: , update_existing_subscriptions: false)
    user.cost_change_requests.create!(old_cost: user.cost, new_cost: new_cost, update_existing_subscriptions: update_existing_subscriptions || false)
    ProfilesMailer.delay.changed_cost(user, user.subscription_cost, user.pretend(cost: new_cost).subscription_cost)
  end

  def reject
    request.rejected = true
    request.rejected_at = Time.zone.now
    request.save!
  end

  def approve
    request.approved = true
    request.approved_at = Time.zone.now
    request.save!
  end

  def change_cost
    UserProfileManager.new(user).change_cost!(cost: request.new_cost, update_existing_subscriptions: request.update_existing_subscriptions)
    request.performed = true
    request.performed_at = Time.zone.now
    request.save!
  end
end
