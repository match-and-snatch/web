RSpec::Matchers.define :delete_record_index_document do |record|
  match do |block|
    refresh_index(index)
    before = query(record)
    refresh_index(index)
    block.call
    refresh_index(index)
    after = query(record)

    expectation.call((before - after).count)
  end

  chain(:from_type) do |type|
    @type = type
  end

  chain(:from_index) do |index_name|
    @index = index_name
  end

  description do
    "delete #{record.class}##{record.id} record from index #{index} / type #{type}"
  end

  failure_message do
    "Expected to delete a #{record.class}##{record.id} record from index #{index} / type #{type}, but nothing was deleted"
  end

  def expectation
    @expectation ||= -> (count) { count == 1 }
  end

  def query(klass)
    Elasticpal::Query.new(index: index, type: type, model: record.class).search(match: {'_id' => record.id}).records
  end

  def index
    @index || record.class.elastic_default_index_name
  end

  def type
    @type || 'default'
  end

  def supports_block_expectations?
    true
  end
end
