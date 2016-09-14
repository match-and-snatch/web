describe ProfileTypeManager do
  describe '#create' do
    context 'title given' do
      subject { described_class.new.create(title: 'some title') }
      it { is_expected.to be_a ProfileType }
      it { is_expected.to be_persisted }
    end

    context 'no title given' do
      subject { described_class.new.create(title: '  ') }

      specify do
        expect { subject }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(title: t_error(:empty)) }
      end
    end

    context 'title is already used' do
      before { described_class.new.create(title: 'dj') }
      subject { described_class.new.create(title: 'dj') }

      specify do
        expect { subject }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(title: t_error(:taken)) }
      end
    end
  end
end
