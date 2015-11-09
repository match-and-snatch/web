namespace :index do
  desc 'Index profiles records into elasticsearch'
  task profiles: :environment do
    Queries::Elastic::Profiles.new.scope.elastic_bulk_index
  end

  desc 'Index users records into elasticsearch'
  task users: :environment do
    User.elastic_bulk_index
  end
end
