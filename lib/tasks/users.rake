namespace :users do
  desc 'Clean comments, likes, posts, uploads etc. for deleted users'
  task clean_stuff: :environment do
    Users::CleanStuffJob.new.perform
  end

  desc 'Import bounce list from Sendgrid'
  task import_bounces: :environment do
    Users::PullEmailBouncesJob.new.perform
  end
end
