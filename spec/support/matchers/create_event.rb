RSpec::Matchers.define :create_event do |expected|
  match do |actual|
    actual.persisted? && actual.action.to_sym == expected.to_sym
  end

  #optional description and failure message definition blocks
end