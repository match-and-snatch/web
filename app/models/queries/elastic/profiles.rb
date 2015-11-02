module Queries
  module Elastic
    class Profiles < Elasticpal::Query
      model 'User'
      type 'public'

      body do |fulltext_query|
        query do
          match name: fulltext_query, has_profile_page: true
        end
      end
    end
  end
end
