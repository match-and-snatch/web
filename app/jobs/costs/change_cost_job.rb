module Costs
  class ChangeCostJob
    def self.perform
      CostChangeRequest.includes(:user).approved.find_each do |cost_change_request|
        UserProfileManager.new(cost_change_request.user).change_cost!(cost: cost_change_request.new_cost,
                                                                      update_existing_subscriptions: cost_change_request.update_existing_subscriptions)
        cost_change_request.perform!
      end
    end
  end
end
