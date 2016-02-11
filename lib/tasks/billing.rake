namespace :billing do
  task cycle: :environment do
    Billing::ChargeJob.new.perform
    Billing::ContributeJob.new.perform
  end

  task duplicates: :environment do
    User.all.each do |user|
      tuids = user.subscriptions.map(&:target_user_id)
      if tuids != tuids.uniq
        puts "#{user.id} - #{user.email}"
        puts tuids.inspect
        puts '==========='
      end
    end
  end

  task fix: :environment do
  end
end
