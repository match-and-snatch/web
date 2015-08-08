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
    @once = true
    @expectation = -> (count) { count.abs == 1 }
  end

  description do
    "create #{klass} record".tap do |result|
      result << " matching #{scope}" if scope.any?
    end
  end

  failure_message do
    if @once
      "Expected to create a single #{klass} record, but created #@created_records_count"
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
    klass.unscoped.where(scope)
  end

  def supports_block_expectations?
    true
  end
end
