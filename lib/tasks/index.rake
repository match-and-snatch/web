namespace :index do
  desc 'Index profiles records into elasticsearch'
  task profiles: :environment do
    Queries::Elastic::Profiles.new.scope.elastic_bulk_index
  end
end
