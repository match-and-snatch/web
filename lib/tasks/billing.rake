namespace :billing do
  task cycle: :environment do
    Billing::ChargeJob.new.perform
    Billing::ContributeJob.new.perform
    Billing::ValidateZipJob.new.perform
  end

  task duplicates: :environment do
    User.all.find_each do |user|
      tuids = user.subscriptions.map(&:target_user_id)
      if tuids != tuids.uniq
        puts "#{user.id} - #{user.email}"
        puts tuids.inspect
        puts '==========='
      end
    end
  end
end
