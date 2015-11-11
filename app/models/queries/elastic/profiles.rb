module Queries
  module Elastic
    class Profiles < Elasticpal::Query
      type 'profiles'

      scope do
        User.profile_owners
            .with_complete_profile
            .where(hidden: false, has_mature_content: false)
            .where('users.subscribers_count > 0 OR users.profile_picture_url IS NOT NULL')
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
              },
              filter: {term: {publicly_visible: true}}
            }
          }
        }
      end
    end
  end
end
