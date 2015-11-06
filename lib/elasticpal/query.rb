require 'elasticpal/client'
require 'elasticpal/response'
require 'elasticsearch/dsl'

module Elasticpal
  class Query
    include Elasticsearch::DSL

    def self.body(&block)
      @body_block = block
    end

    def self.body_block
      @body_block
    end

    def self.index(index_name)
      define_method :index do
        index_name
      end
    end

    def self.model(model_name = nil, &block)
      if block
        define_method :model, &block
      else
        define_method :model do
          model_name.classify.constantize
        end
      end
    end

    def self.scope(*args, &block)
      self.model(*args, &block)
    end

    def self.type(type_name)
      define_method :type do
        type_name
      end
    end

    def initialize(index: nil, model: nil, type: nil, arguments: {})
      @index = index
      @model = model
      @type = type
      @arguments = arguments

      if !@model && @index
        @model = @index.classify.constantize
      end
    end

    alias_method :dsl_search, :search

    # @param arguments [Hash]
    #
    # @example
    #   ElasticPal::Query.new(model: 'Profile', index: 'User').search do
    #     query do
    #       match title: 'Foo'
    #     end
    #   end
    #
    # @example
    #   ElasticPal::Query.new(model: 'Profile', index: 'User').search(title: 'Foo')
    def search(*args, &block)
      plain_query = @arguments.merge(type: type, index: index)

      if block
        plain_query[:body] = instance_eval(&block)
      else
        plain_query[:body] = instance_exec(*args, &self.class.body_block)
      end

      Elasticpal::Response.new(client.search(plain_query), self)
    end

    def delete
      client.delete_by_query(@arguments.merge(index: @index, type: @type, body: {query: {match_all: {}}}))
    end

    def client
      Elasticpal::Client.instance
    end

    def index
      @index ||= model.name.downcase.pluralize
    end

    def model
      @model or raise NotImplementedError
    end

    def scope
      model
    end

    def type
      @type ||= 'default'.freeze
    end
  end
end
