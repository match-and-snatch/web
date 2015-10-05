RSpec::Matchers.define :create_record do |klass|
  match do |block|
    before = query(klass).all.to_a
    block.call
    after = query(klass).all.to_a

    @created_records_count = (after - before).count

    expectation.call(@created_records_count)
  end

  chain(:matching) do |attrs|
    scope.merge!(attrs)
  end

  chain(:once) do
    fail ArgumentError, '`exactly` and `once` chains cannot be used together' if @exact_count
    @once = true
    @expectation = -> (count) { count.abs == 1 }
  end

  chain(:exactly) do |count|
    count = count.is_a?(Enumerator) ? count.count : count.to_i
    return once if count == 1

    fail ArgumentError, '`exactly` and `once` chains cannot be used together' if @once

    @exact_count = count
    @expectation = -> (cnt) { cnt.abs == @exact_count }
  end

  description do
    "create #{klass} record".tap do |result|
      result << " matching #{scope}" if scope.any?
    end
  end

  failure_message do
    if @once
      "Expected to create a single #{klass} record, but created #{@created_records_count}"
    elsif @exact_count
      "Expected to create #{exact_count} #{klass} records, but created #{@created_records_count}"
    else
      "Expected to create a #{klass} record, but nothing was created"
    end
  end

  def expectation
    @expectation ||= -> (count) { count != 0 }
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