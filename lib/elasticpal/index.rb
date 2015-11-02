module Elasticpal
  class Indexable
    extend ActiveSupport::Concern

    class Indexator
      def initialize(record)
        @record = record
      end

      def index
        each_index do |index|
          index.index(record)
        end
      end

      def delete
        each_index do |index|
          index.delete(record)
        end
      end

      private

      def each_index(&block)
        @record.class.elastic_indexes.each do |_ ,index|
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

      def field(*names, params)
        names.each do |name|
          declare_field name, params
        end
      end

      def declare_field(name, params)
        fields[name] = params
      end

      def index(record)
        client.xput
        # Do your indexation logic here
      end

      def client
        Elasticpal::Client.instance
      end
    end

    class Index
      attr_reader :types

      def initialize(name, &block)
        @name = name
        @types = []
        instance_eval(&block)
      end

      def type(name = 'default', &block)
        types << Type.new(name, index, &block)
      end

      def index(record)
        types.each do |type|
          type.index(record)
        end
      end
    end

    def elastic_index_document
      elastic_indexator.index_document(self)
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

      def elastic_type(name = nil, &block)
        elastic_indexes[elastic_default_index_name] ||= Index.new(elastic_default_index_name)
        elastic_indexes[elastic_default_index_name].type(name, &block)
      end

      def elastic_default_index_name
        name.underscore.pluralize
      end
    end
  end
end

