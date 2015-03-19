namespace :stats do
  desc 'Try to restore some stats data to daily stats events'
  task populate: :environment do
    Stats::PopulateStatsJob.perform
  end
end
