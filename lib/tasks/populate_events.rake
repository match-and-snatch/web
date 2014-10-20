namespace :events do
  desc 'Populate events for existing things and past actions'
  task populate: :environment do
    Events::PopulateJob.perform
  end
end
