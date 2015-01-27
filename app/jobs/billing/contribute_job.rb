module Billing
  class ContributeJob
    def self.perform
      puts "============================"
      puts "       CONTRIBUTIONS"
      puts "============================"
      Contribution.to_charge.find_each do |contribution|
        if contribution.user
          p "Contributing ##{contribution.id}" unless Rails.env.test?
          ContributionManager.new(user: contribution.user, contribution: contribution).create_child
        end
      end
    end
  end
end

