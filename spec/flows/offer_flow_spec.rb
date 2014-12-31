describe OfferFlow do
  let(:performer) { User.create! }
  subject(:flow) { OfferFlow.new(performer: performer) }

  describe '#create' do
    let(:create) { flow.create(title: 'test') }

    it { expect { create }.to change { flow.offer }.from(nil).to(instance_of(Offer)) }
    it { expect { create }.to change { Offer.count }.by(1) }

    context 'no title set' do
      let(:create) { flow.create(title: ' ') }

      it { expect { create }.not_to change { flow.offer }.from(nil) }
      it { expect { create }.not_to change { Offer.count } }
      it { expect { create }.to change { flow.errors }.from({}).to eq(title: [:cannot_be_blank]) }
    end

    describe 'offer' do
      before { create }
      subject(:offer) { flow.offer }

      it { expect(offer.user).to eq(performer) }
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }
    end
  end

  describe '#add_to_favorites' do
    before { flow.create(title: 'test') }

    let(:add_to_favorites) { flow.add_to_favorites }

    it { expect { add_to_favorites }.to change { flow.offer.favorites.count }.from(0).to(1) }

    describe 'favorite' do
      before { add_to_favorites }
      subject(:favorite) { flow.offer.favorites.first }

      it { expect(favorite.user).to eq(performer) }
    end
  end
end