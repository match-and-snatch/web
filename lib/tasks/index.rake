namespace :index do
  desc 'Index public profiles'
  task profiles_autocomplete: :environment do
    Queries::Elastic::Profiles.new.scope.elastic_bulk_index(type: 'profiles')
  end

  desc 'Index users autocomplete'
  task users_autocomplete: :environment do
    User.unscoped.elastic_bulk_index(type: 'default')
  end

  task all: [:profiles_autocomplete, :users_autocomplete]
end
