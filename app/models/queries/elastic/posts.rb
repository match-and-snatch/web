module Queries
  module Elastic
    class Posts < Elasticpal::Query
      scope { Post }

      body do |fulltext_query: , user_id: nil, include_hidden: false, from: 0, size: 5|
        filters = {}
        filters[:hidden] = false unless include_hidden
        filters[:user_id] = user_id if user_id

        query = {multi_match: {
            query: fulltext_query,
            fields: %w(title^3 message)
        }}

        unless filters.empty?
          query = {filtered: {
              query: query,
              filter: filters.map { |k, v| {term: {k => v}} }
          }}
        end

        {
          from: from,
          size: size,
          query: query,
          sort: [{pinned: {order: 'desc'}}, {created_at: {order: 'desc'}}, '_score']
        }
      end
    end
  end
end
