namespace :events do
  desc 'Generate and store s3 paths for existing uploads'
  task populate_subjects: :environment do
    Events::PopulateSubjectsJob.perform
  end

  desc 'Clear old events'
  task clear: :environment do
    Events::ClearJob.perform
  end

  desc 'Populate data and store it as jsonb'
  task populate_data: :environment do
    Events::PopulateDataJob.perform
  end
end
