module Billing
  class ContributeJob
    def self.perform
      unless Rails.env.test?
        puts "============================"
        puts "       CONTRIBUTIONS"
        puts "============================"
      end

      Contribution.to_charge.find_each do |contribution|
        if contribution.user
          p "Contributing ##{contribution.id}" unless Rails.env.test?
          ContributionManager.new(user: contribution.user, contribution: contribution).create_child
        end
      end
    end
  end
end

