namespace :posts do
  desc 'Remove posts from removed profiles 30 days left after profile removement'
  task clean: :environment do
    puts 'Processing started'
    Posts::CleanJob.perform
  end
end
