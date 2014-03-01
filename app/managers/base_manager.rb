class BaseManager

  private

  # @param message [String, Symbol]
  # @return [String]
  def t(message)
    I18n.t message
  end

  # @param message [String, Hash]
  def error_message(message)
    case message
    when String
      {message: message}
    when Hash
      message
    when Symbol
      {message => 'is not valid'}
    else
      raise ArgumentError, 'Unspecified failure'
    end
  end

  # @param message [String, Hash]
  def fail_with!(message)
    raise ManagerError, error_message(message)
  end

  # @param message [String, Hash]
  def fail_with(message)
    @errors.reverse_merge!(error_message(message))
  end

  def validate!
    @errors ||= {}
    yield if block_given?
    @errors.empty? or raise ManagerError, @errors
  end
end

