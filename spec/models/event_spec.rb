describe Event do
  subject { described_class.create!(action: 'test', data: {a: 1}).reload }

  its(:action) { is_expected.to eq('test') }
  its(:data) { is_expected.to eq('a' => 1) }
end
