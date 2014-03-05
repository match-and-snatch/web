class BaseManager

  private

  # @param message [String, Symbol]
  # @param opts [Hash]
  # @return [String]
  def t(message, opts = {})
    I18n.t message, opts.reverse_merge(scope: :errors, default: [:default, message])
  end

  # @param message [String, Hash]
  # @return [Hash]
  def error_message(message)
    case message
    when String
      {message: message}
    when Hash
      {}.tap do |result|
        message.each do |k, v|
          case v
          when String
            result[k] = v
          when Symbol
            result[k] = t(v)
          when Hash
            [].tap do |messages|
              v.each do |translation_key, locals|
                messages << t(translation_key, locals)
              end
              result[k] = messages.to_sentence
            end
          end
        end
      end
    when Symbol
      {message => t(:invalid)}
    when ActiveModel::Errors
      message.to_hash.tap do |result|
        result.each do |key, value|
          result[key] = value.to_sentence
        end
      end
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

