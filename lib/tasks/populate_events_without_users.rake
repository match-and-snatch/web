namespace :events do
  desc 'Populate events for existing things and past actions'
  task populate_without_users: :environment do
    Events::PopulateWithoutUsersJob.perform
  end
end