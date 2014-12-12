namespace :uploads do
  desc 'Generate and store s3 paths for existing uploads'
  task generate_s3_paths: :environment do
    Uploads::GenerateS3PathsJob.new.perform
  end
end
