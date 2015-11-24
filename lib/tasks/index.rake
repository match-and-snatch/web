namespace :index do
  desc 'Index public profiles'
  task profiles_autocomplete: :environment do
    Queries::Elastic::Profiles.new.scope.elastic_bulk_index(type: 'profiles')
  end

  desc 'Index users autocomplete'
  task users_autocomplete: :environment do
    User.unscoped.elastic_bulk_index(type: 'default')
  end

  desc 'Index user metions per subscription'
  task mentions: :environment do
    Queries::Elastic::Mentions.new.scope.includes(:subscriptions).elastic_bulk_index(type: 'mentions')
  end

  desc 'Index posts'
  task posts: :environment do
    Post.unscoped.elastic_bulk_index
  end

  task all: %i[profiles_autocomplete mentions users_autocomplete posts]
end
