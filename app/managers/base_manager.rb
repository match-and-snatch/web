class BaseManager

  # @return [Hash]
  def errors
    @errors ||= {}
  end

  # @return [String, nil]
  def failure_message
    @failure_message
  end

  def failed?
    errors.any? || failure_message.present?
  end

  def valid?
    !failed?
  end

  protected

  # Saves record, fails with manager error if record is invalid
  # @raise [ManagerError]
  # @param record [ActiveRecord::Base] model
  def save_or_die!(record)
    record.save or fail_with! record.errors
  end

  private

  # @param message [String, Symbol]
  # @param opts [Hash]
  # @return [String]
  def t(message, opts = {})
    I18n.t message, opts.reverse_merge(scope: :errors, default: [:default, message])
  end

  # @raise [ManagerError]
  def fail!
    raise ManagerError, {message: failure_message, errors: errors}
  end

  # @param message [String, Hash]
  def fail_with!(message)
    fail_with message
    fail!
  end

  # @param message [String, Hash]
  def fail_with(message)
    case message
    when String then @failure_message = message
    when Symbol then errors[message] = t(:invalid)
    when Hash
      message.each do |k, v|
        case v
        when String then errors[k] = v
        when Symbol then errors[k] = t(v)
        when Hash
          messages = v.map { |translation_key, locals| t(translation_key, locals) }
          errors[k] = messages.to_sentence
        end
      end
    when ActiveModel::Errors
      message.to_hash.each do |key, value|
        errors[key] = value.to_sentence
      end
    else
      raise ArgumentError, 'Unspecified failure'
    end
  end

  # @raise [ManagerError] if manager action is invalid
  def validate!
    yield if block_given?
    valid? or fail!
  end
end

