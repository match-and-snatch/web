namespace :index do
  task profiles: :environment do
    Queries::Elastic::Profiles.new.scope.find_each do |user|
      puts "Indexing #{user.id}"
      user.elastic_index_document
    end
  end
end
