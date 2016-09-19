module Queries
  module Elastic
    class Profiles < Elasticpal::Query
      type 'profiles'

      scope do
        User.profile_owners.with_complete_profile
      end

      body do |fulltext_query, include_hidden: false|
        query = {
          query: {
            function_score: {
              query: {
                dis_max: {
                  queries: [
                    {match: {profile_name: fulltext_query}},
                    {match: {full_name: fulltext_query}},
                    {match: {profile_types_text: fulltext_query}}
                  ]
                }
              },
              field_value_factor: {
                field: 'subscribers_count',
                modifier: 'log1p',
                factor: 0.15
              },
              boost_mode: 'sum'
            }
          }
        }
        query[:filter] = {term: {publicly_visible: true}} unless include_hidden

        {query: {filtered: query}}
      end
    end
  end
end
