namespace :events do
  desc 'Generate and store s3 paths for existing uploads'
  task populate_subjects: :environment do
    Events::PopulateSubjectsJob.perform
  end
end
