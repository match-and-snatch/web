module Queries
  module Elastic
    class Mentions < Elasticpal::Query
      type 'mentions'

      scope do
        User.joins("LEFT OUTER JOIN subscriptions ON users.id = subscriptions.user_id AND subscriptions.rejected = 'f'")
          .group('users.id')
          .having('(COUNT(subscriptions.id) > 0 OR users.subscribers_count > 0)')
      end

      body do |fulltext_query, profile_id: nil|
        query = {dis_max: {
          queries: [{match: {profile_name: fulltext_query}},
                    {match: {full_name: fulltext_query}}]
        }}

        if profile_id
          query = {filtered: {
                    query: query,
                    filter: {
                      term: {subscription_target_user_ids: profile_id}
                    }
                  }}
        end

        {query: query, size: 5}
      end
    end
  end
end

