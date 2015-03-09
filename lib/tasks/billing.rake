namespace :billing do
  task cycle: :environment do
    Billing::ChargeJob.perform
    Billing::ContributeJob.perform
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

  desc 'Set charge date to subscriptions'
  task populate_charge_date: :environment do
    Billing::PopulateChargeDateJob.perform
  end
end
