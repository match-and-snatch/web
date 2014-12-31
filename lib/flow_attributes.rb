class FlowAttributes
  attr_reader :data, :flow

  delegate :performer, to: :flow

  # @param flow [Flow]
  # @param hash [Hash]
  def initialize(flow, hash, &block)
    @flow = flow
    @data = hash.with_indifferent_access
    @attrs = {}
    instance_eval(&block) if block
  end

  # @param name [Symbol]
  # @return [FlowAttribute]
  def attr(name)
    @attrs[name] = FlowAttribute.new(self, name)
  end

  def [](key)
    @attrs[key]
  end

  # @return [Hash<Symbol, Array>]
  def errors
    @errors ||= {}.tap do |result|
      @attrs.each do |name, attr|
        result[name] = attr.errors unless attr.valid?
      end
    end
  end

  def to_h
    {}.tap do |result|
      @attrs.each do |name, attr|
        result[name] = attr.value
      end
    end
  end

  def valid?
    errors.empty?
  end

  private

  class FlowAttribute
    attr_reader :name

    # @param data [Hash]
    # @param name [Symbol]
    def initialize(attrs, name)
      @name = name.to_sym
      @attrs = attrs
      @value = @attrs.data[@name]
      @validators = []
    end

    # @return [Array<Symbol>]
    def errors
      @errors ||= @validators.map { |v| v.error_for(value) }.compact
    end

    def map_to(value)
      case value
      when Symbol
        @value = -> { @attrs[@name] }
      else
        @value = value
      end

      self
    end

    def require
      @validators << PresenceValidator.new
      self
    end

    def valid?
      errors.empty?
    end

    def value
      @cahed_value ||= @value.is_a?(Proc) ? @value.call : @value
    end
  end

  class Validator

    # @param name [Symbol]
    # @param options [Hash]
    def initialize(options = {})
      @options = options
    end

    def error_for(value)
      self.class::ERROR if failed?(value)
    end

    def failed?(value)
      raise NotImplementedError
    end
  end

  class PresenceValidator < Validator
    ERROR = :cannot_be_blank

    def failed?(value)
      value.blank?
    end
  end
end