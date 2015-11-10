module Queries
  module Elastic
    class Users < Elasticpal::Query
      scope do
        User
      end

      body do |fulltext_query|
        {
          query: {
            filtered: {
              query: {
                function_score: {
                  query: {
                    dis_max: {
                      queries: [
                        {match: {profile_name: fulltext_query}},
                        {match: {full_name: fulltext_query}}
                      ]
                    }
                  }
                }
              }
            }
          }
        }
      end
    end
  end
end
