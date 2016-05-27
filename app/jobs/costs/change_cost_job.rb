module Costs
  class ChangeCostJob
    include Concerns::Jobs::Reportable

    def perform
      report = new_report requests_to_processing: requests.count, performed_requests: 0, failed_requests: 0

      requests.find_each do |cost_change_request|
        begin
          UserProfileManager.new(cost_change_request.user)
              .change_cost!(cost: cost_change_request.new_cost, update_existing_subscriptions: cost_change_request.update_existing_subscriptions)
          cost_change_request.perform!
          report[:performed_requests] += 1
        rescue ManagerError => e
          report.log_failure(e.message)
          report[:failed_requests] += 1
        end
      end

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end

    private

    def requests
      CostChangeRequest.includes(:user).approved.not_performed
    end
  end
end
