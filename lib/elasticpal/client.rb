require 'multi_json'
require 'faraday'
require 'elasticsearch/api'

module Elasticpal
  class Client
    include Elasticsearch::API
    include Singleton

    # @param method [String]
    # @param path [String]
    # @param params [Hash]
    # @param body [Hash, nil]
    # @return [Faraday::Response]
    def perform_request(method, path, params, body)
      return EmptyResponse.instance unless config[:enabled]

      connection.run_request(
        method.downcase.to_sym,
        path,
        (body ? convert_to_json(body) : nil),
        {'Content-Type' => 'application/json'})
    end

    # @return [Faraday::Connection]
    def connection
      @connection ||= ::Faraday::Connection.new url: config[:url]
    end

    # @return [Hash<Symbol>]
    def config
      @config ||= YAML.load_file(Rails.root.join('config', 'elasticpal.yml'))[ENV['RAILS_ENV'] || Rails.env].symbolize_keys
    end

    private

    def convert_to_json(body = nil)
      body.is_a?(String) ? body : MultiJson.dump(body)
    end

    class EmptyResponse
      include Singleton

      def body
        @body ||= {}.freeze
      end
    end
  end
end
