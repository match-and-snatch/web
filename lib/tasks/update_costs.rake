namespace :costs do
  desc 'Update costs by approved requests'
  task update: :environment do
    Costs::ChangeCostJob.new.perform
  end
end
