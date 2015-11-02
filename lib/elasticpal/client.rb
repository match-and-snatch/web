require 'multi_json'
require 'faraday'
require 'elasticsearch/api'

module Elasticpal
  class Client
    include Elasticsearch::API
    include Singleton

    def perform_request(method, path, params, body)
      return EmptyResponse.new unless config[:enabled]

      connection.run_request(
        method.downcase.to_sym,
        path,
        (body ? MultiJson.dump(body): nil),
        {'Content-Type' => 'application/json'})
    end

    def connection
      @connection ||= ::Faraday::Connection.new url: config[:url]
    end

    def config
      @config ||= YAML.load_file(Rails.root.join('config', 'elasticpal.yml'))[ENV['RAILS_ENV'] || Rails.env].symbolize_keys
    end

    class EmptyResponse
      def body
        {}
      end
    end
  end
end
