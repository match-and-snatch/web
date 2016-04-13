namespace :posts do
  desc 'Remove posts from removed profiles 30 days left after profile removement'
  task clean: :environment do |t, args|
    puts 'Processing started'
    Posts::CleanJob.new(ids: args.extras).perform if args.extras.any?
  end
end
