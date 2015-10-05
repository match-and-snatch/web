module Flows
  class CompactData < Struct.new(:record_id, :class_name)

    # @param record [ActiveRecord::Base, Hash]
    def self.pack(record)
      case record
      when ActiveRecord::Base
        new(record.id, record.class.name)
      when Hash
        CompactHash.new(record)
      else
        record
      end
    end

    def unpack
      class_name.constantize.find_by_id(record_id)
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