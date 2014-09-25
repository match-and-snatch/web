RSpec::Matchers.define :create_event do |expected|
  match do |actual|
    if actual.is_a?(Proc)
      Proc.call
      true # TODO : WUT?
    else
      actual.persisted? && actual.action.to_sym == expected.to_sym
    end
  end

  match_when_negated do |actual|
    if actual.is_a?(Proc)
      Proc.call
      true # TODO : WUT?
    else
      !actual.persisted?
    end
  end

  def supports_block_expectations?
    true
  end
end