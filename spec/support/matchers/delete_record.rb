RSpec::Matchers.define :delete_record do |klass|
  match do |block|
    before = query(klass).all.to_a
    block.call
    after = query(klass).all.to_a

    @deleted_records_count = (before - after).count

    expectation.call(@deleted_records_count)
  end

  chain(:matching) do |attrs|
    scope.merge!(attrs)
  end

  chain(:once) do
    fail ArgumentError, '`exactly` and `once` chains cannot be used together' if @exact_count
    @once = true
    @expectation = -> (count) { count == 1 }
  end

  chain(:exactly) do |count|
    count = count.is_a?(Enumerator) ? count.count : count.to_i
    return once if count == 1

    fail ArgumentError, '`exactly` and `once` chains cannot be used together' if @once

    @exact_count = count
    @expectation = -> (cnt) { cnt == @exact_count }
  end

  description do
    "delete #{klass} record".tap do |result|
      result << " matching #{scope}" if scope.any?
    end
  end

  failure_message do
    if @once
      "Expected to delete a single #{klass} record, but deleted #{@deleted_records_count}"
    elsif @exact_count
      "Expected to delete #{@exact_count} #{klass} records, but delete #{@deleted_records_count}"
    else
      "Expected to delete a #{klass} record, but nothing was deleted"
    end
  end

  def expectation
    @expectation ||= -> (count) { count > 0 }
  end

  def scope
    @scope ||= {}
  end

  def query(klass)
    klass.where(scope)
  end

  def supports_block_expectations?
    true
  end
end
