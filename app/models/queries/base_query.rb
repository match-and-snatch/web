module Queries
  class BaseQuery
    private

    # @param results [Enumerable]
    # @param limit [Integer]
    # @return [Array]
    def limit(results, limit = 5)
      case results
        when Array
          Kaminari.paginate_array(results).page.per(limit)
        when ActiveRecord::Relation
          results.limit(limit).to_a
        when Enumerable
          results.to_a.first(limit)
        else
          raise ArgumentError, 'Invalid results collection'
      end
    end
  end
end
