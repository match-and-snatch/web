namespace :reports do
  desc 'Send daily snapshot report'
  task daily_snapshot: :environment do
    Reports::DailySnapshot.new.perform
  end
end
