namespace :events do
  desc 'Populate events for existing things and past actions'
  task populate: :environment do
    Events::PopulateJob.perform
  end

  desc 'Populate events for existing things and past actions'
  task populate_without_users: :environment do
    Events::PopulateWithoutUsersJob.perform
  end

  desc 'Populate events with \'profile_created\' action'
  task populate_profile_created_events: :environment do
    Events::RepopulateProfileCreatedEventsJob.perform
  end

  desc 'Remove duplicates events'
  task remove_duplicates: :environment do
    puts "<<<=== STARTED #{Time.zone.now}"
    Events::RemoveDuplicatesJob.perform
    puts ">>>=== FINISHED #{Time.zone.now}"
  end
end
