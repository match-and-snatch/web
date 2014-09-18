namespace :events do
  task populate: :environment do
    Events::PopulateJob.perform
  end
end
