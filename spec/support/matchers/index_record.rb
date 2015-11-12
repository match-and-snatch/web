RSpec::Matchers.define :index_record do |record|
  match do |block|
    @record = record
    Elasticpal::Client.clear_data
    refresh_index(index) rescue nil
    before = query(record) rescue []
    refresh_index(index) rescue nil
    block.call
    refresh_index(index) rescue nil
    after = query(record) rescue []

    expectation.call((after - before).count)
  end

  chain(:using_type) do |type|
    @type = type
  end

  chain(:using_index) do |index_name|
    @index = index_name
  end

  description do
    "index #{record.class}##{record.id} record using index #{index} / type #{type}"
  end

  failure_message do
    "Expected to index #{record.class}##{record.id} record using index #{index} / type #{type}, but nothing was indexed"
  end

  def expectation
    @expectation ||= -> (count) { count == 1 }
  end

  def query(record)
    Elasticpal::Query.new(index: index, type: type, model: record.class).search({match: {_id: record.id}}).records
  end

  def index
    @index || record.class.elastic_default_index_name
  end

  def type
    @type || 'default'
  end

  def record
    @record
  end

  def supports_block_expectations?
    true
  end
end
