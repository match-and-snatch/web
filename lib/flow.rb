class Flow
  attr_reader :performer
  attr_reader :errors
  attr_reader :states

  # @return [Hash] Flows used by this flow
  def self.flows; @flows ||= {} end

  # @return [Class] Subject class
  def self.klass; @klass end

  # @return [Symbol] Subject instance var name
  def self.instance_name; @instance_name end

  # @return [Symbol] Subject virtual name
  def self.subject_name; @subject_name end

  # @param name [Symbol]
  # @param class_name [String]
  def self.subject(name, class_name: nil)
    raise 'Subject has been already set' if @subject_set

    class_name ||= name.to_s
    @klass = class_name.classify.constantize
    @subject_name = name.to_sym
    @instance_name = :"@#@subject_name"

    define_method(name) { subject }
    @subject_set = true
  end

  # Creates object by described set of rules
  # @param name [Symbol]
  # @return [self]
  def self.factory(name = nil, &block)
    autoset_subject
    name = name ? "create_#{name}" : 'create'

    define_method name do |attributes|
      raise 'Cannot call factory on existing subject' if subject.try(:persisted?)

      transaction do
        attributes = FlowAttributes.new(self, attributes, &block)

        if attributes.valid?
          result = subject || self.class.klass.new
          result.attributes = attributes.to_h
          save set_subject result
        else
          invalidate!(attributes.errors)
        end
      end

      self
    end
  end

  # Updates object by described set of rules
  # @param name [Symbol]
  # @return [self]
  def self.update(name = nil, &block)
    autoset_subject
    name = name ? "update_#{name}" : 'update'

    define_method name do |attributes|
      transaction do
        attributes = FlowAttributes.new(self, attributes, &block)

        if attributes.valid?
          subject.attributes = attributes.to_h
          save
        else
          invalidate!(attributes.errors)
        end
      end

      self
    end
  end

  # @param name [Symbol]
  def self.flow(_name = nil, &block)
    autoset_subject

    flows[_name.to_sym] = if block
      Class.new(Flow) do
        eval("def self.name; '#{_name}' end")
        instance_eval(&block)
      end
    else
      _name.to_s.classify.constantize
    end
  end

  # @param name [Symbol] no ! bang names allowed
  def self.action(name, &block)
    autoset_subject
    base_name = :"__#{name}"
    define_method(base_name, &block)

    define_method name do |*args|
      raise ArgumentError, 'No subject set' unless subject
      transaction { public_send(base_name, *args); self }
    end
  end

  def self.autoset_subject
    return if @subject_set

    subject_name = name.gsub(/Flow$/, '').gsub(/.+::/, '').underscore
    subject subject_name.to_sym
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

  def klass
    self.class.klass
  end

  def failed?
    errors.any?
  end

  def flows
    @flows
  end

  # @return [ActiveRecord::Base]
  def subject
    instance_variable_get(self.class.instance_name)
  end

  def passed?
    !failed?
  end

  def success
    yield if valid?
  end

  def failure
    yield if failed?
  end

  protected

  # @param errors [Hash]
  # @raise [FlowError]
  def invalidate!(errors)
    invalidate(errors)
    fail!
  end

  # @param errors [Hash]
  def invalidate(errors)
    @errors.merge!(errors.symbolize_keys)

    if has_parent?
      @parent.invalidate(self.class.subject_name => @errors)
    end
  end

  private

  # @raise [FlowError]
  def fail!
    raise FlowError
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
