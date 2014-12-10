namespace :posts do
  desc 'Remove posts from removed profiles 30 days left after profile removement'
  task clean: :environment do
    Posts::CleanJob.perform
  end
end
