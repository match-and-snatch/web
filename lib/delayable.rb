module Delayable
  def delay(queue: nil)
    @queue = queue
    delayer
  end

  def delayer
    @delayer ||= ::Delayable::Delayer.new(self)
  end

  def perform(method_name, *args)
    public_send(method_name, *delayer.decode_args(args))
  end

  def queue
    @queue or raise NotImplementedError
  end
end
