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

  desc 'Rebuild indexes'
  task rebuild: :environment do
    User.elastic_rebuild_index!
    Post.elastic_rebuild_index!
  end

  desc 'Index all'
  task all: %i[rebuild profiles_autocomplete mentions users_autocomplete posts]
end
