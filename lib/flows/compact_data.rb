module Flows
  class CompactData < Struct.new(:record_id, :class_name, :attributes)

    # @param record [ActiveRecord::Base, Hash]
    def self.pack(record)
      case record
      when ActiveRecord::Base
        if record.persisted?
          new(record.id, record.class.name)
        else
          new(record.id, record.class.name, record.attributes)
        end
      when Hash
        CompactHash.new(record)
      else
        record
      end
    end

    def unpack
      model = class_name.constantize
      result = model.find_by_id(record_id)

      if attributes.present?
        if result
          result.attributes = attributes
        else
          model.new(attributes)
        end
      else
        result
      end
    end

    class CompactHash < Hash

      # @param hash [Hash]
      def initialize(hash)
        super()
        hash.each { |k, v| self[k] = v }
      end

      def []=(k, v)
        super k, CompactData.pack(v)
      end

      def unpack
        {}.tap do |result|
          each do |k, v|
            result[k] = case v
                        when CompactData, CompactHash then v.unpack
                        else
                          v
                        end
          end
        end
      end
    end
  end
end