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
                  },
                  field_value_factor: {
                    field: 'subscribers_count',
                    modifier: 'log1p',
                    factor: 0.05
                  },
                  boost_mode: 'sum'
                }
              }
            }
          }
        }
      end
    end
  end
end
