module Elasticpal
  module Indexable
    extend ActiveSupport::Concern

    class Indexator
      def initialize(record)
        @record = record
      end

      def index_document
        each_index do |index|
          index.index_document(@record)
        end
      end

      def delete_document
        each_index do |index|
          index.delete_document(@record)
        end.map
      end

      private

      def each_index(&block)
        @record.class.elastic_indexes.map do |_ ,index|
          block.call(index)
        end
      end
    end

    class Type
      attr_reader :fields

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

      def index_document(record)
        client.index index: @index.name,
                     type: @name,
                     id: record.id,
                     body: body(record),
                     refresh: true
      end

      def client
        Elasticpal::Client.instance
      end

      private

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
      attr_reader :types
      attr_reader :name

      def initialize(name, &block)
        @name = name
        @types = []
        instance_eval(&block) if block
      end

      def type(name = 'default', &block)
        types << Type.new(name, self, &block)
      end

      def index_document(record)
        types.map do |type|
          type.index_document(record)
        end
      end
    end

    def elastic_index_document
      elastic_indexator.index_document
    end

    def elastic_delete_document
      elastic_indexator.delete_document
    end

    def elastic_indexator
      Indexator.new(self)
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
    end
  end
end

