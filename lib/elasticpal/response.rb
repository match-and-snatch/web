module Elasticpal
  class Response
    def initialize(response, query = nil)
      @plain_response = response
      @query = query
      @scope = @query.try(:model)
    end

    def records(scope = {})
      results = relation(scope).to_a
      ids.map do |id|
        results.find { |x| x.id == id }
      end.compact.sort do |r1, r2|
        order(r2) <=> order(r1)
      end
    end

    def relation(scope = {})
      @scope.where(id: ids).where(scope)
    end

    def ids
      hits.map { |hit| hit['_id'] }.map(&:to_i)
    end

    def any?
      hits.any?
    end

    def hits
      @hits ||= hits_data['hits']
    end

    def hits_data
      @hits_data ||= response['hits']
    end

    def max_score
      hits_data['max_score']
    end

    def total
      hits_data['total']
    end

    def order(record)
      hit = hits.find { |hit| hit['_id'] == record.id.to_s }
      hit.has_key?('sort') ? hit['sort'] : hit['_score']
    end

    def response
      @response ||= parse_plain_response(@plain_response)
    end

    private

    def parse_plain_response(response)
      if response.is_a?(String)
        JSON.parse(response)
      else
        raise ArgumentError
      end
    end
  end
end
