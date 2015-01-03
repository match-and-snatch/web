class FlowsProxy

  # @param flow [Flow]
  def initialize(flow)
    @flow = flow
    @flow_instances = {}
  end

  def method_missing(*args)
    case args.count
    when 1, 2
      method_name = args.first
      flow_class = @flow.class.flows[method_name.to_sym] or return super
      subject = args.second

      (@flow_instances[method_name] ||= {})[subject] ||= flow_class.new(subject: subject,
                                                                        performer: @flow.performer,
                                                                        parent: @flow)
    else
      super
    end
  end
end
