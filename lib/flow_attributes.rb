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

  # @param name [Symbol]
  # @return [FlowAttribute]
  def vattr(name)
    @attrs[name] = FlowAttribute.new(self, name, true)
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
        result[name] = attr.value unless attr.virtual?
      end
    end
  end

  def valid?
    errors.empty?
  end

  def method_missing(name, *args)
    @attrs[name] ? @attrs[name].value : super
  end

  private

  class FlowAttribute
    attr_reader :name

    # @param name [Symbol]
    # @return [FlowAttribute]
    def self.chain(name, &block)
      define_method name do |*args|
        instance_exec(*args, &block)
        self
      end
    end

    # @param data [Hash]
    # @param name [Symbol]
    # @param virtual [true, false]
    def initialize(attrs, name, virtual = false)
      @name = name.to_sym
      @attrs = attrs
      @value = @attrs.data[@name]
      @validators = []
      @virtual = virtual
    end

    chain :array do
      @validators << Validator.new(message: :not_an_array) { |v| v.is_a?(Array) }
    end

    chain :email do
      @validators << EmailValidator.new
    end

    chain :uniq do
      @validators << Validator.new(message: :already_taken) { |v| @attrs.flow.klass.where(@name => v).empty? }
    end

    chain :password do
      @validators << Validator.new(message: :too_short) { |v| v.try(:length).to_i > 5 }
    end

    chain :equal_to do |value|
      @validators << Validator.new(message: :does_not_match) { |v| v == (value.is_a?(Proc) ? value.call : value) }
    end

    chain :boolean do
      @validators << BooleanValidator.new
      v = @value
      @value = -> {
        case v
        when 0, false, '0', 'false', 'no', '-', -> (value) { value.blank? }
          false
        else
          true
        end
      }
    end

    chain :map_to do |value|
      case value
      when Symbol
        @value = -> { @attrs[@name] }
      else
        @value = value
      end
    end

    chain :require do |message = :cannot_be_empty|
      @validators << Validator.new(message: message) { |v| v.present? || v === false }
    end

    # @return [Array<Symbol>]
    def errors
      @errors ||= @validators.map { |v| v.error_for(value) }.compact
    end

    def valid?
      errors.empty?
    end

    def value
      @cahed_value ||= @value.is_a?(Proc) ? @value.call : @value
    end

    def virtual?
      @virtual
    end
  end

  class Validator

    # @param name [Symbol]
    # @param options [Hash]
    def initialize(options = {}, &block)
      @options = options
      @block = block
    end

    def error_for(value)
      error_message unless valid?(value)
    end

    def error_message
      @options[:message] || :invalid
    end

    def valid?(value)
      @block.call(value)
    end
  end

  class BooleanValidator < Validator
    VALID_VALUES = [1,0,true,false,'1','0','true','false','yes','no','+','-']

    def error_message
      :not_a_boolean
    end

    def valid?(value)
      VALID_VALUES.include?(value)
    end
  end

  class EmailValidator < Validator
    EMAIL_REGEXP = /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/

    def error_message
      :not_an_email
    end

    def valid?(value)
      !!value.match(EMAIL_REGEXP)
    end
  end
end