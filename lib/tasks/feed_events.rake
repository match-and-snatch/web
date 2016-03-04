namespace :feed_events do
  desc 'Add uploads count info to feed events'
  task populate_uploads_count_info: :environment do
    FeedEvents::PopulateUploadsCountToDataJob.perform
  end
end
