module Concerns::CostUpdatePerformer
  # @param cost_change_request [CostChangeRequest]
  # @param update_existing_subscriptions [Boolean]
  def approve_and_change_cost!(cost_change_request, update_existing_subscriptions: false)
    cost_change_request.approve!(update_existing_costs: update_existing_subscriptions)
    if cost_change_request.initial? || user.source_subscriptions.active.empty?
      change_cost!(cost: cost_change_request.new_cost, update_existing_subscriptions: cost_change_request.update_existing_subscriptions)
      cost_change_request.perform!
    end
  end

  # @param cost_change_request [CostChangeRequest]
  # @param cost [Integer]
  def rollback_cost!(cost_change_request, cost: nil)
    if cost
      if cost_change_request.initial?
        raise ArgumentError, "You can't rollback cost for a newcomer"
      end

      validate! { validate_cost cost }

      user.cost = (cost.to_f * 100).to_i
      save_or_die! user
    end

    cost_change_request.reject!
  end

  # @param ids [Array]
  # @param update_existing_subscriptions [Boolean]
  def self.approve_requests(ids = [], update_existing_subscriptions: false)
    raise BulkEmptySetError, 'No requests selected' if ids.blank?

    ActiveRecord::Base.transaction do
      CostChangeRequest.includes(:user).where(id: ids).find_each do |cost_change_request|
        UserProfileManager.new(cost_change_request.user).approve_and_change_cost!(cost_change_request, update_existing_subscriptions: update_existing_subscriptions)
      end
    end
  end

# @param ids [Array]
  def self.reject_requests(ids = [])
    raise BulkEmptySetError, 'No requests selected' if ids.blank?

    ActiveRecord::Base.transaction do
      CostChangeRequest.includes(:user).where(id: ids).find_each do |cost_change_request|
        UserProfileManager.new(cost_change_request.user).rollback_cost!(cost_change_request)
      end
    end
  end
end
