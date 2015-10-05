module Billing
  class ContributeJob
    def self.perform
      unless Rails.env.test?
        puts '============================'
        puts '       CONTRIBUTIONS'
        puts '============================'
      end

      Contribution.to_charge.find_each do |contribution|
        user = contribution.user

        if user && !user.locked?
          begin
            p "Contributing ##{contribution.id}" unless Rails.env.test?
            ContributionManager.new(user: user, contribution: contribution).create_child
          rescue ManagerError => e
            puts "Failed making contribution ##{contribution.id}: #{e.message}"
          end
        end
      end
    end
  end
end

