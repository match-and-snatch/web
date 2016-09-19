require 'elasticpal/client'
require 'elasticpal/response'

module Elasticpal
  class Query

    # Defines query body
    # @example
    #   class ProfilesQuery < Elasticpal::Query
    #     type 'profiles'
    #
    #     scope do
    #       User.with_complete_profile
    #     end
    #
    #     body do |fulltext_query|
    #       {
    #         query: {
    #           filtered: {
    #             query: {
    #               function_score: {
    #                 query: {
    #                   dis_max: {
    #                     queries: [
    #                       {match: {profile_name: fulltext_query}},
    #                       {match: {full_name: fulltext_query}},
    #                     ]
    #                   }
    #                 },
    #                 field_value_factor: {
    #                   field: 'subscribers_count',
    #                   modifier: 'log1p',
    #                   factor: 0.15
    #                 },
    #                 boost_mode: 'sum'
    #               }
    #             },
    #             filter: {term: {visible: true}}
    #           }
    #         }
    #       }
    #     end
    #   end
    #
    #   ProfilesQuery.search('John Doe')
    # @yield
    def self.body(&block)
      @body_block = block
    end

    def self.body_block
      @body_block
    end

    # Sets index to use
    # @param index_name [String]
    def self.index(index_name)
      define_method :index do
        index_name
      end
    end

    # Sets model to perform query on
    # @param model_name [String]
    # @yield model class
    def self.model(model_name = nil, &block)
      if block
        define_method :model, &block
      else
        define_method :model do
          model_name.classify.constantize
        end
      end
    end

    # Sets default scope to perform query on
    # @param model_name [String]
    # @yield model scope
    def self.scope(*args, &block)
      self.model(*args, &block)
    end

    # Sets type within which query will be performed, default is 'default'
    # @param type_name [String]
    def self.type(type_name)
      define_method :type do
        type_name
      end
    end

    def self.search(*args)
      new.search(*args)
    end

    # @param index [String]
    # @param type [String]
    # @param model [Class]
    # @param arguments [Hash]
    def initialize(index: nil, type: nil, model: nil, arguments: {})
      @index = index
      @model = model
      @type = type
      @arguments = arguments

      if !@model && @index
        @model = @index.classify.constantize
      end
    end

    # @param arguments [Hash]
    #
    # @example
    #   ElasticPal::Query.new(model: 'Profile', index: 'User').search do |title|
    #     {match: {title: title}}
    #   end
    #
    # @example
    #   ElasticPal::Query.new(model: 'Profile', index: 'User').search(title: 'Foo')
    def search(*args, &block)
      plain_query = @arguments.merge(type: type, index: index)

      if block
        plain_query[:body] = instance_eval(&block)
      else
        if self.class.body_block
          plain_query[:body] = instance_exec(*args, &self.class.body_block)
        else
          q = args.first
          raise ArgumentError unless q.is_a?(Hash)
          plain_query[:body] = {query: q}
        end
      end

      Elasticpal::Response.new(client.search(plain_query), self).tap do |r|
        if r.response['error'].present?
          raise InvalidResponseError, r.response['error'].inspect
        end
      end
    end

    # Removes documents from the index type
    # @param batch_size [Integer]
    def delete(batch_size: 100)
      scope.find_in_batches(batch_size: batch_size) do |group|
        client.bulk(body: group.map { |record| {delete: {_index: index, _type: type, _id: record.id}} })
      end
    end

    def client
      Elasticpal::Client.instance
    end

    # @return [String]
    def index
      @index ||= model.name.downcase.pluralize
    end

    # @return [Class]
    def model
      @model or raise NotImplementedError
    end

    # @return [ActiveRecord::Relation, Class]
    def scope
      model
    end

    # @return [String] 'default' by default
    def type
      @type ||= 'default'.freeze
    end

    class InvalidResponseError < StandardError
    end
  end
end
