module Flows
  class Payload < Hash
    def initialize(source = nil)
      super()
      merge!(source) if source
      # raise ArgumentError, 'Subject must be set' unless subject
      # raise ArgumentError, 'Performer must be set' unless performer
    end

    def subject
      self[:subject]
    end

    def performer
      self[:performer]
    end
  end
end