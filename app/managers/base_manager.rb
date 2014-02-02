class BaseManager

  # @param message [String, Hash]
  def fail_with!(message)
    case message
    when String
      raise ManagerError, {message: message}
    when Hash
      raise ManagerError, message
    else
      raise ArgumentError, 'Unspecified failure'
    end
  end
end

