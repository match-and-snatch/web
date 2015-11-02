module Queries
  module Elastic
    class Profiles < Elasticpal::Query
      model 'User'

      body do |fulltext_query|
        query do
          match profile_name: fulltext_query
        end
      end
    end
  end
end
