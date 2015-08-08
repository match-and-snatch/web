module Flows
  class Base
    attr_accessor :performer
    attr_accessor :failure_callback
    attr_reader :errors
    attr_reader :states
    attr_reader :result
    attr_reader :parent

    # @param controller [Flows::Protocol]
    # @param subject [ActiveRecord::Base]
    def self.init(controller, subject: nil)
      raise ArgumentError unless controller.is_a?(Flows::Protocol)
      new(performer: controller.flow_performer, subject: subject || controller.flow_subject).tap do |flow|
        flow.failure_callback = controller.flow_failure_callback
      end
    end

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

      define_method name do |attributes = {}|
        raise 'Cannot call factory on existing subject' if subject.try(:persisted?)

        transaction do
          action = Flows::Action.new(self, attributes, &block)

          if action.valid?
            new_subject = subject || self.class.klass.new
            new_subject.attributes = action.attributes

            (save set_subject new_subject).tap do
              action.run_success_callbacks(self)
              @result = new_subject
            end
          else
            invalidate!(action.errors)
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
          action = Flows::Action.new(self, attributes, &block)

          if action.valid?
            subject.attributes = action.attributes
            @result = save.tap { action.run_success_callbacks(self) }
          else
            invalidate!(action.errors)
          end
        end

        self
      end
    end

    # @param name [Symbol]
    def self.flow(_name = nil, &block)
      autoset_subject

      flows[_name.to_sym] = if block
                              Class.new(Flows::Base) do
                                eval("def self.name; '#{_name}' end")
                                instance_eval(&block)
                              end
                            else
                              _name.to_s.classify.constantize
                            end
    end

    # @param name [Symbol] no ! bang names allowed
    def self.action(name, requires_subject: true, &block)
      autoset_subject
      base_name = :"__#{name}"
      define_method(base_name, &block)

      define_method name do |*args|
        if requires_subject
          raise ArgumentError, 'No subject set' unless subject
        end
        transaction do
          result = public_send(base_name, *args)
          @result = result.is_a?(::Flows::Base) ? result.result : result
          self
        end
      end
    end

    def self.autoset_subject
      return if @subject_set

      subject_name = name.gsub(/Flow$/, '').gsub(/.+::/, '').underscore
      subject subject_name.to_sym
    end

    # @param performer [User]
    # @param subject [ActiveRecord::Base, nil]
    # @param parent [Flows::Base]
    def initialize(performer: , subject: nil, parent: nil)
      @parent = parent
      set_subject(subject)

      unless subject.nil?
        raise ArgumentError unless subject.is_a?(self.class.klass)
      end

      @performer = performer
      # raise ArgumentError unless performer.is_a?(User)

      @errors = {}
      @states = []
      @flows = Flows::Proxy.new(self)
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

    def pass(&block)
      if passed?
        block.call(result)
      elsif failure_callback
        failure_callback.call(self)
      end
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

    def with_subject(new_subject)
      raise ArgumentError, 'Subject already set' if subject
      set_subject(new_subject)
      self
    end

    protected

    # @param errors [Hash]
    # @raise [Flows::Error]
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

    # @raise [Flows::Error]
    def fail!
      raise Flows::Error
    end

    # @param notification_name [Symbol]
    # @param payload [Hash<Symbol, *>]
    def notify(notification_name, payload)
      Publisher.notify(notification_name,
                       CompactData.pack(performer),
                       Time.zone.now.to_i,
                       CompactData.pack(payload))
    end

    # @param state [*]
    def push_state(state)
      states.push(state)
      states.uniq!
    end

    # @param object [ActiveRecord::Base]
    def save(object = subject)
      raise ArgumentError unless object.is_a?(ActiveRecord::Base)

      object.save.tap do |saved_object|
        invalidate!(saved_object.class.name.underscore.to_sym => object.errors) unless saved_object
      end
    end

    # @param subject [ActiveRecord::Base]
    def set_subject(subject)
      instance_variable_set(self.class.instance_name, subject)
    end

    def transaction(&block)
      ActiveRecord::Base.transaction(&block)
    rescue Flows::Error => e
      raise e if has_parent?
      self
    end

    def has_parent?
      !!@parent
    end
  end
end