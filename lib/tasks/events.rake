namespace :events do
  desc 'Clear old events'
  task clear: :environment do
    Events::ClearJob.perform
  end
end
