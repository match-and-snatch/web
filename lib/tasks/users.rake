namespace :users do
  desc 'Clean comments, likes, posts, uploads etc. for deleted users'
  task clean_stuff: :environment do
    Users::CleanStuffJob.new.perform
  end
end
