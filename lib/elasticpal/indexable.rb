module Elasticpal
  module Indexable
    extend ActiveSupport::Concern

    class Indexator

      # @param record [ActiveRecord::Base]
      # @param type_name [String] e.g. default, profiles
      def initialize(record, type_name: nil)
        @record = record
        @type_name = type_name

        if @type_name.present? && !each_index(&:type_names).flatten.include?(@type_name)
          raise ArgumentError, "Can't find type with name #{@type_name}"
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
        each_index { |index| index.index_data(@record, type_name: @type_name) }.flatten
      end

      # @return [Array<Hash>]
      def delete_data
        each_index { |index| index.delete_data(@record, type_name: @type_name) }.flatten
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
      # @param type_name [String]
      # @return [Array<Hash>]
      def index_data(record, type_name: nil)
        each_types(type_name: type_name) do |type|
          type.index_data(record)
        end
      end

      # @param record [ActiveRecord::Base]
      # @param type_name [String]
      # @return [Array<Hash>]
      def delete_data(record, type_name: nil)
        each_types(type_name: type_name) do |type|
          type.delete_data(record)
        end
      end

      # @return [Array<String>]
      def type_names
        @type_names ||= types.map(&:name)
      end

      private

      # @param type_name [String]
      def each_types(type_name: nil, &block)
        (type_name ? types.select {|t| t.name == type_name} : types).map do |type|
          block.call(type)
        end
      end
    end

    # @param type_name [String]
    def elastic_index_document(type_name: nil)
      elastic_indexator(type_name: type_name).index_document
    end

    # @param type_name [String]
    def elastic_delete_document(type_name: nil)
      elastic_indexator(type_name: type_name).delete_document
    end

    # @param type_name [String]
    # @return [Array<Hash>]
    def elastic_index_data(type_name: nil)
      elastic_indexator(type_name: type_name).index_data
    end

    # @param type_name [String]
    # @return [Array<Hash>]
    def elastic_delete_data(type_name: nil)
      elastic_indexator(type_name: type_name).delete_data
    end

    # @param type_name [String]
    # @return [Indexator]
    def elastic_indexator(type_name: nil)
      Indexator.new(self, type_name: type_name)
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
      # @param type_name [String]
      def elastic_bulk_index(batch_size: 100, type_name: nil)
        find_in_batches(batch_size: batch_size) do |group|
          Elasticpal::Client.instance.bulk(body: group.flat_map { |record| record.elastic_index_data(type_name: type_name) }, refresh: true)
        end
      end
    end
  end
end

