namespace :duplicates do
  task clean: :environment do
    Users::DuplicateRemovalJob.new.perform
  end

  task clean_subscriptions: :environment do
    Subscriptions::DuplicateRemovalJob.perform
  end
end

