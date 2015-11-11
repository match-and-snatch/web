module Elasticpal
  module Indexable
    extend ActiveSupport::Concern

    class Indexator

      # @param record [ActiveRecord::Base]
      # @param type [String] e.g. default, profiles
      def initialize(record, type: nil)
        @record = record
        @type = type

        if @type.present? && !each_index(&:types).flatten.include?(@type)
          raise ArgumentError, "Can't find type with name #{@type}"
        end
      end

      def index_document
        client.bulk body: index_data, refresh: true
      end

      def delete_document
        client.bulk body: delete_data, refresh: true
      end

      # @return [Array<Hash>]
      def index_data
        each_index { |index| index.index_data(@record, type: @type) }.flatten
      end

      # @return [Array<Hash>]
      def delete_data
        each_index { |index| index.delete_data(@record, type: @type) }.flatten
      end

      private

      def each_index(&block)
        @record.class.elastic_indexes.map do |_ ,index|
          block.call(index)
        end
      end

      def client
        Elasticpal::Client.instance
      end
    end

    class Type
      attr_reader :name, :fields

      # @param name [String]
      # @param index [Index]
      def initialize(name, index, &block)
        @name = name
        @index = index
        @fields = {}

        instance_eval(&block)
      end

      def field(*names, &block)
        params = names.extract_options!

        names.each do |name|
          declare_field(name, params, &block)
        end
      end

      def declare_field(name, params, &block)
        fields[name] = params.merge(value_block: block)
      end

      # @param record [ActiveRecord::Base]
      # @return [Hash]
      def index_data(record)
        {
          index: {
            _index: @index.name,
            _type: @name,
            _id: record.id,
            data: body(record)
          }
        }
      end

      # @param record [ActiveRecord::Base]
      # @return [Hash]
      def delete_data(record)
        {
          delete: {
            _index: @index.name,
            _type: @name,
            _id: record.id
          }
        }
      end

      private

      # @param record [ActiveRecord::Base]
      # @return [Hash]
      def body(record)
        {}.tap do |result|
          fields.each do |name, params|
            if params[:value_block]
              result[name] = record.instance_eval(&params[:value_block])
            else
              result[name] = record.send(name)
            end
          end
        end
      end
    end

    class Index
      attr_reader :name, :types

      # @param name [String]
      def initialize(name, &block)
        @name = name
        @types = []
        instance_eval(&block) if block
      end

      def type(name = 'default', &block)
        types << Type.new(name, self, &block)
      end

      # @param record [ActiveRecord::Base]
      # @param type [String]
      # @return [Array<Hash>]
      def index_data(record, type: nil)
        each_types(type: type) do |type|
          type.index_data(record)
        end
      end

      # @param record [ActiveRecord::Base]
      # @param type [String]
      # @return [Array<Hash>]
      def delete_data(record, type: nil)
        each_types(type: type) do |type|
          type.delete_data(record)
        end
      end

      # @return [Array<String>]
      def types
        @types ||= types.map(&:name)
      end

      private

      # @param type [String]
      def each_types(type: nil, &block)
        (type ? types.select {|t| t.name == type} : types).map do |type|
          block.call(type)
        end
      end
    end

    # @param type [String]
    def elastic_index_document(type: nil)
      elastic_indexator(type: type).index_document
    end

    # @param type [String]
    def elastic_delete_document(type: nil)
      elastic_indexator(type: type).delete_document
    end

    # @param type [String]
    # @return [Array<Hash>]
    def elastic_index_data(type: nil)
      elastic_indexator(type: type).index_data
    end

    # @param type [String]
    # @return [Array<Hash>]
    def elastic_delete_data(type: nil)
      elastic_indexator(type: type).delete_data
    end

    # @param type [String]
    # @return [Indexator]
    def elastic_indexator(type: nil)
      Indexator.new(self, type: type)
    end

    module ClassMethods

      def elastic_indexes
        @elastic_indexes ||= {}
      end

      def elastic_index(name = nil, &block)
        name ||= elastic_default_index_name
        elastic_indexes[name] = Index.new(name, &block)
      end

      def elastic_type(name = 'default', &block)
        elastic_indexes[elastic_default_index_name] ||= Index.new(elastic_default_index_name)
        elastic_indexes[elastic_default_index_name].type(name, &block)
      end

      def elastic_default_index_name
        name.underscore.pluralize
      end

      # @param batch_size [Integer]
      # @param type [String]
      def elastic_bulk_index(batch_size: 100, type: nil)
        find_in_batches(batch_size: batch_size) do |group|
          Elasticpal::Client.instance.bulk(body: group.flat_map { |record| record.elastic_index_data(type: type) }, refresh: true)
        end
      end
    end
  end
end

