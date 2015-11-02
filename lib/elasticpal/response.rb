module Elasticpal
  class Response
    def initialize(response, query = nil)
      @response = if response.is_a?(String)
                    JSON.parse(response)
                  else
                    raise ArgumentError
                  end
      @query = query
      @scope = @query.try(:model)
    end

    def records(scope = {})
      @scope.where(scope).where(id: ids).sort_by do |record|
        hits.find { |hit| hit['_id'] == record.id.to_s }['_score']
      end
    end

    def ids
      hits.map { |hit| hit['_id'] }
    end

    def any?
      hits.any?
    end

    def hits
      @hits ||= hits_data['hits']
    end

    def hits_data
      @hits_data ||= @response['hits']
    end

    def max_score
      hits_data['max_score']
    end

    def total
      hits_data['total']
    end
  end
end