module Billing
  class ContributeJob
    include Concerns::Jobs::Reportable

    def perform
      report = new_report contributions_to_charge: Contribution.to_charge.count,
                          skipped_charges: 0,
                          successful_charges: 0,
                          failed_charges: 0

      unless Rails.env.test?
        puts '============================'
        puts '       CONTRIBUTIONS'
        puts '============================'
      end

      Contribution.to_charge.find_each do |contribution|
        user = contribution.user

        if contribution.recurring_performable?
          begin
            p "Contributing ##{contribution.id}" unless Rails.env.test?
            ContributionManager.new(user: user, contribution: contribution).create_child
            report[:successful_charges] += 1
          rescue ManagerError => e
            puts "Failed making contribution ##{contribution.id}: #{e.message}"
            report.log_failure(e.message)
            report[:failed_charges] += 1
          end
        else
          report[:skipped_charges] += 1
        end
      end

      report.forward
    rescue => e
      report.log_failure(e.message)
      report.forward
      raise
    end
  end
end
