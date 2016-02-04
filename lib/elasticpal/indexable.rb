module Elasticpal
  module Indexable
    extend ActiveSupport::Concern

    class Indexator

      # @param record [ActiveRecord::Base]
      # @param type [String] e.g. default, profiles
      def initialize(record, type: nil)
        @record = record
        @type = type

        if @type.present? && !each_index(&:type_names).flatten.include?(@type)
          raise ArgumentError, "Can't find type with name #{@type}"
        end
      end

      # Indexes a document
      def index_document
        client.bulk body: index_query_body, refresh: true
      end

      # Removes document from an index
      def delete_document
        client.bulk body: delete_query_body, refresh: true
      end

      # @return [Array<Hash>]
      def index_query_body
        each_index { |index| index.index_query_body(@record, type: @type) }.flatten
      end

      # @return [Array<Hash>]
      def delete_query_body
        each_index { |index| index.delete_query_body(@record, type: @type) }.flatten
      end

      private

      def each_index(&block)
        klass = case @record
                when ActiveRecord::Base
                  @record.class.base_class
                else
                  @record.class
                end

        klass.elastic_indexes.map do |_ ,index|
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

      # @param names [Array<Symbol>] method / field / attribute names
      # @param options [Hash]
      # @yield value
      def field(*names, &block)
        params = names.extract_options!

        names.each do |name|
          declare_field(name, params, &block)
        end
      end

      # @param name [Symbol] method / field / attribute name
      # @param params [Hash] field options
      # @yield value
      def declare_field(name, params, &block)
        fields[name] = params.merge(value_block: block)
      end

      # @param record [ActiveRecord::Base]
      # @return [Hash]
      def index_query_body(record)
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
      def delete_query_body(record)
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
              result[name.to_s.sub(/\?$/, '').to_sym] = record.send(name)
            end
          end
        end
      end
    end

    class Index
      attr_reader :name, :types

      # @param name [String]
      def initialize(name)
        @name = name
        @types = []
      end

      def type(name = 'default', &block)
        types << Type.new(name, self, &block)
      end

      # @param record [ActiveRecord::Base]
      # @param type [String]
      # @return [Array<Hash>]
      def index_query_body(record, type: nil)
        map_types(type: type) do |type|
          type.index_query_body(record)
        end
      end

      # @param record [ActiveRecord::Base]
      # @param type [String]
      # @return [Array<Hash>]
      def delete_query_body(record, type: nil)
        map_types(type: type) do |type|
          type.delete_query_body(record)
        end
      end

      # @return [Array<String>]
      def type_names
        @type_names ||= types.map(&:name)
      end

      private

      # @param type [String]
      def map_types(type: nil, &block)
        (type ? types.select {|t| t.name == type} : types).map do |type|
          block.call(type)
        end
      end
    end

    class IndexBuilder
      attr_reader :index

      # @param index [Index]
      def initialize(index)
        @index = index
      end

      # @return [Hash]
      def params
        {}.tap do |res|
          index.types.each do |type|
            type.fields.each do |field_name, params|
              if params.has_key?(:partial)
                (res[:settings] ||= {}).tap do |settings|
                  (settings[:analysis] ||= {}).tap do |analysis|
                    (analysis[:filter] ||= {}).tap do |filter|
                      filter["#{type.name}_#{field_name}_ngram_filter".to_sym] = {
                        type: 'edge_ngram',
                        min_gram: params[:partial].is_a?(Hash) ? params[:partial][:min_gram] || 2 : 2,
                        max_gram: params[:partial].is_a?(Hash) ? params[:partial][:max_gram] || 20 : 20
                      }
                    end
                    (analysis[:analyzer] ||= {}).tap do |analyzer|
                      analyzer["#{type.name}_#{field_name}_ngram_analyzer".to_sym] = {
                        type: 'custom',
                        tokenizer: 'standard',
                        filter: ['lowercase', "#{type.name}_#{field_name}_ngram_filter"]
                      }
                    end
                  end
                end

                (res[:mappings] ||= {}).tap do |mappings|
                  (mappings[type.name.to_sym] ||= {}).tap do |mapping_type|
                    (mapping_type[:properties] ||= {}).tap do |properties|
                      properties[field_name.to_sym] = {
                        type: 'string',
                        analyzer: "#{type.name}_#{field_name}_ngram_analyzer",
                        search_analyzer: 'standard'
                      }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end

    # Reindexes current document
    # @param type [String]
    def elastic_index_document(type: nil)
      elastic_indexator(type: type).index_document
    end

    # Removes current document from index
    # @param type [String]
    def elastic_delete_document(type: nil)
      elastic_indexator(type: type).delete_document
    end

    # @param type [String]
    # @return [Indexator]
    def elastic_indexator(type: nil)
      Indexator.new(self, type: type)
    end

    module ClassMethods

      # @return [Hash<String, Elasticpal::Index>]
      def elastic_indexes
        @elastic_indexes ||= {}
      end

      # @param name [String]
      # @param block
      # @example
      #   class User < ActiveRecord::batch_size
      #     elastic_index 'profiles' do
      #       elastic_type do
      #         field :name, :slug
      #       end
      #
      #       elastic_type 'admins' do
      #         field :full_name
      #       end
      #
      #       def slug
      #         name.parameterize
      #       end
      #     end
      #
      #     elastic_index do # default to 'users'
      #       elastic_type do # default to 'default'
      #         field :name
      #       end
      #     end
      #   end
      def elastic_index(name = nil, &block)
        name ||= elastic_default_index_name
        elastic_indexes[name] = Index.new(name)
        instance_eval(&block) if block
      end

      # @param name [String]
      # @param block
      # @example
      #   class User < ActiveRecord::batch_size
      #     elastic_type 'admins' do
      #       field :full_name
      #     end
      #
      #     elastic_type do # default to 'default'
      #       field :name, :slug
      #     end
      #
      #     def slug
      #       name.parameterize
      #     end
      #   end
      def elastic_type(name = 'default', &block)
        elastic_indexes[elastic_default_index_name] ||= Index.new(elastic_default_index_name)
        elastic_indexes[elastic_default_index_name].type(name, &block)
      end

      # @return [String]
      def elastic_default_index_name
        name.underscore.pluralize
      end

      # @param batch_size [Integer]
      # @param type [String]
      def elastic_bulk_index(batch_size: 100, type: nil)
        find_in_batches(batch_size: batch_size) do |group|
          bulk_query = group.flat_map do |record|
            record.elastic_indexator(type: type).index_query_body
          end

          Elasticpal::Client.bulk(body: bulk_query, refresh: true)
        end
      end

      # @param name [String] index name
      def elastic_rebuild_index!(name = nil)
        if name.present? && !elastic_indexes.keys.include?(name)
          raise ArgumentError, "Can't find index with name #{name}"
        end

        Elasticpal::Client.delete_index(name || elastic_indexes.keys)
        (name ? {name => elastic_indexes[name]} : elastic_indexes).each do |index_name, index|
          Elasticpal::Client.create_index(index_name, params: IndexBuilder.new(index).params)
        end
      end
    end
  end
end
