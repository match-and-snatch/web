require 'multi_json'
require 'faraday'
require 'elasticsearch/api'

module Elasticpal
  class Client
    include Elasticsearch::API
    include Singleton

    class << self
      delegate :bulk, :perform_request, :connection, :config, :clear_data, :delete_index, :refresh_index, to: :instance
    end

    # @param method [String]
    # @param path [String]
    # @param params [Hash]
    # @param body [Hash, nil]
    # @return [Faraday::Response, EmptyResponse]
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

    # Deletes all indices
    def clear_data
      delete_index '_all'
    end

    # @param name [String] index name
    def delete_index(name)
      indices.delete index: name
    end

    # @param name [String] index name
    def refresh_index(name = '_all')
      indices.refresh index: name
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
