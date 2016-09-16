describe ActionController::ManagebleParameters do
  subject { described_class.new(params) }

  let(:params) { {} }

  describe '#slice' do
    it { expect(subject.slice).to eq({}) }
    it { expect(subject.slice(:key)).to eq({}) }

    context 'params are present' do
      let(:params) { {key: 'value', item: 'thing'} }

      it { expect(subject.slice(:key)).to eq({key: 'value'}) }
      it { expect(subject.slice(:key, :item)).to eq(params) }
      it { expect(subject.slice([:key, :item])).to eq(params) }
      it { expect(subject.slice([:key, [:item]])).to eq(params) }

      context 'param is a hash' do
        let(:params) { {key: 'value', hash: {item: 'thing'}} }
        it { expect(subject.slice(:hash)).to eq({hash: {'item' => 'thing'}}) }
      end
    end
  end
end
