module Costs
  class ChangeCostJob
    def self.perform
      CostChangeRequest.approved.find_each do |cost_change_request|
        CostChangeRequestManager.new(request: cost_change_request).change_cost
      end
    end
  end
end