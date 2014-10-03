module Delayable
  class Delayer
    attr_reader :delayable

    # @param delayable [Delayable]
    def initialize(delayable)
      raise ArgumentError unless delayable.is_a?(Delayable)
      @delayable = delayable
    end

    def method_missing(method_name, *args)
      if Rails.env.production?
        Resque.enqueue(delayable, method_name.to_s, *encode_args(args))
      else
        delayable.perform(method_name, *encode_args(args))
      end
    rescue Resque::TermException
      Resque.enqueue(self, method_name, *args)
    end

    def decode_args(args)
      args.map do |arg|
        raise ArgumentError unless arg.to_s.starts_with?('###___')

        arg = arg.gsub('###___', '')
        klass, value = arg.split('___:::___')
        klass = klass.constantize

        case [klass]
          when [ActiveRecord::Base]
            model, id = value.split('-')
            model.constantize.find(id)
          when [String]
            value
          when [Integer]
            value.to_i
          when [Float]
            value.to_f
          when [Fixnum]
            value.to_i
          else
            raise ArgumentError, "Not expected #{klass.name}"
        end
      end
    end

    private

    def encode_args(args)
      args.map do |arg|
        case arg
          when ActiveRecord::Base
            "###___#{ActiveRecord::Base.name}___:::___#{arg.class.name}-#{arg.id}"
          when String, Integer, Float, Fixnum
            "###___#{arg.class.name}___:::___#{arg}"
          else
            raise ArgumentError, "Delayed #{arg.class.name} is not Supported"
        end
      end
    end
  end
end
