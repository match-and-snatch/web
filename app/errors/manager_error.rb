class ManagerError < StandardError
  attr_reader :messages

  # @param messages [Hash]
  def initialize(messages)
    @messages = messages
  end

  # @return [String]
  def message
    if messages.many?
      messages.map(&:to_sentence).to_sentence
    elsif messages[:message]
      messages.values.first
    elsif messages.any?
      "#{messages.keys.first} #{messages.values.first}"
    end
  end
end
