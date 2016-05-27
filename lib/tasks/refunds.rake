namespace :refunds do
  desc 'Download refunds from Stripe'
  task download: :environment do |t, args|
    puts 'Processing started'
    Refunds::DownloadJob.new.perform
  end
end
