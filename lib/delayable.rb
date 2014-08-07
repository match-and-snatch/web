module Delayable
  def delay
    delayer
  end

  def delayer
    @delayer ||= ::Delayable::Delayer.new(self)
  end

  def perform_without_delay(method_name, *args)
    public_send(method_name, *delayer.decode_args(args))
  end

  def queue
    raise NotImplementedError
  end
end
