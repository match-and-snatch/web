namespace :duplicates do
  task clean: :environment do
    Users::DuplicateRemovalJob.new.perform
  end
end

