module Queries
  module Elastic
    class Posts < Elasticpal::Query
      scope { Post }

      body do |fulltext_query: , user_id: nil, include_hidden: false|
        filters = {}
        filters[:hidden] = false unless include_hidden
        filters[:user_id] = user_id if user_id

        {
          query: {
            filtered: {
              query: {
                dis_max: {
                  queries: [
                    {match: {message: fulltext_query}},
                    {match: {title: fulltext_query}}
                  ]
                }
              },
              filter: filters.map{|k, v| {term: {k => v}}}
            }
          },
          sort: [{created_at: {order: 'desc'}}]
        }
      end
    end
  end
end

