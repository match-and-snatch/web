class ManagerError < StandardError
  attr_reader :messages

  # @param messages [Hash]
  def initialize(messages)
    @messages = messages
  end

  # @return [String]
  def message
    messages.map(&:to_sentence).to_sentence
  end
end
