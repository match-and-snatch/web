namespace :index do
  task profiles: :environment do
    Queries::Elastic::Profiles.new.scope.find_each do |user|
      user.elastic_index_document
    end
  end
end
