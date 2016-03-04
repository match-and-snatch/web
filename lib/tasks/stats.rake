namespace :stats do
  desc 'Try to restore some stats data to daily stats events'
  task populate: :environment do
    Stats::PopulateStatsJob.perform
  end

  desc 'Update gross sales field for users'
  task update_gross_sales: :environment do
    Stats::UpdateGrossSalesStatsJob.perform
  end
end
