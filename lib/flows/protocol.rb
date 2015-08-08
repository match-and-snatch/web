module Flows
  module Protocol

    def flow_performer
      raise NotImplementedError
    end

    def flow_subject
    end

    def flow_failure_callback
      raise NotImplementedError
    end
  end
end