class Flow

  # @return [Hash] Flows used by this flow
  def self.flows; @flows ||= {} end

  # @return [Class] Subject class
  def self.klass; @klass end

  # @return [Symbol] Subject instance var name
  def self.instance_name; @instance_name end

  # @param name [Symbol]
  # @param class_name [String]
  def self.subject(name, class_name: nil)
    class_name ||= name.to_s
    @klass = class_name.classify.constantize
    @instance_name = :"@#{name}"

    define_method(name) { subject }

    attr_reader :performer
    attr_reader :errors
    attr_reader :states
  end

  # Creates object by described set of rules
  # @param name [Symbol]
  # @return [self]
  def self.factory(name = nil, &block)
    name = name ? "create_#{name}" : 'create'

    define_method name do |attributes|
      return if subject

      transaction do
        attributes = FlowAttributes.new(self, attributes, &block)

        if attributes.valid?
          result = self.class.klass.new(attributes.to_h)
          save set_subject result
        else
          invalidate!(attributes.errors)
        end
      end

      self
    end
  end

  # @param name [Symbol]
  def self.flow(name = nil, &block)
    flows[name.to_sym] = block ? Class.new(Flow, &block) : name.to_s.classify.constantize
  end

  # @param name [Symbol] no ! bang names allowed
  def self.action(name, &block)
    base_name = :"__#{name}"
    define_method(base_name, &block)

    define_method name do |*args|
      raise ArgumentError, 'No subject set' unless subject
      transaction { public_send(base_name, *args); self }
    end
  end

  # @param performer [User]
  # @param subject [ActiveRecord::Base, nil]
  # @param parent [Flow]
  def initialize(performer: , subject: nil, parent: nil)
    @parent = parent
    set_subject(subject)

    unless subject.nil?
      raise ArgumentError unless subject.is_a?(self.class.klass)
    end

    @performer = performer
    raise ArgumentError unless performer.is_a?(User)

    @errors = {}
    @states = []
    @flows = FlowsProxy.new(self)
  end

  def failed?
    errors.any?
  end

  # @return [ActiveRecord::Base]
  def subject
    instance_variable_get(self.class.instance_name)
  end

  private

  # @raise [FlowError]
  def fail!
    raise FlowError
  end

  # @param errors [Hash]
  def invalidate(errors)
    @errors.merge!(errors.symbolize_keys)
  end

  # @param errors [Hash]
  # @raise [FlowError]
  def invalidate!(errors)
    invalidate(errors)
    fail!
  end

  # @param state [*]
  def push_state(state)
    states.push(state)
    states.uniq!
  end

  # @param object [ActiveRecord::Base]
  def save(object = subject)
    raise ArgumentError unless object.is_a?(ActiveRecord::Base)

    object.save.tap do |result|
      invalidate!(result.class.name.underscore.to_sym => result.erros) unless result
    end
  end

  # @param subject [ActiveRecord::Base]
  def set_subject(subject)
    instance_variable_set(self.class.instance_name, subject)
  end

  def transaction(&block)
    ActiveRecord::Base.transaction(&block)
  rescue FlowError => e
    raise e if has_parent?
  end

  def has_parent?
    !!@parent
  end
end

