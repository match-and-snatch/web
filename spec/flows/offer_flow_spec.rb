describe OfferFlow do
  let(:performer) { User.create! }
  let(:tag) { create_tag }

  subject(:flow) { described_class.new(performer: performer) }

  describe '#create' do
    let(:create) { flow.create(title: 'test', tag_ids: [tag.id]) }

    it { expect { create }.to change { flow.offer }.from(nil).to(instance_of(Offer)) }
    it { expect { create }.to change { Offer.count }.by(1) }

    context 'no title set' do
      let(:create) { flow.create(title: ' ', tag_ids: [tag.id]) }

      it { expect { create }.not_to change { flow.offer }.from(nil) }
      it { expect { create }.not_to change { Offer.count } }
      it { expect { create }.to change { flow.errors }.from({}).to eq(title: [:cannot_be_empty]) }
    end

    context 'no tags set' do
      let(:create) { flow.create(title: 'test', tag_ids: []) }

      it { expect { create }.not_to change { flow.offer }.from(nil) }
      it { expect { create }.not_to change { Offer.count } }
      it { expect { create }.to change { flow.errors }.from({}).to eq(tag_ids: [:missing_tag]) }
    end

    describe 'offer' do
      before { create }
      subject(:offer) { flow.offer }

      it { expect(offer.user).to eq(performer) }
      it { expect(offer.tags).to eq([tag]) }
      it { expect(offer.messages_enabled?).to eq(false) }
      it { expect(offer.calls_enabled?).to eq(false) }
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }

      context 'communication enabled' do
        let(:create) { flow.create(title: 'test', tag_ids: [tag.id], messages_enabled: true, calls_enabled: true) }

        it { expect(offer.messages_enabled?).to eq(true) }
        it { expect(offer.calls_enabled?).to eq(true) }
      end
    end
  end

  describe '#create_without_tags' do
    let(:create) { flow.create_without_tags(title: 'test', tag_ids: [tag.id]) }

    it { expect { create }.to change { flow.offer }.from(nil).to(instance_of(Offer)) }
    it { expect { create }.to change { Offer.count }.by(1) }

    context 'no title set' do
      let(:create) { flow.create(title: ' ', tag_ids: [tag.id]) }

      it { expect { create }.not_to change { flow.offer }.from(nil) }
      it { expect { create }.not_to change { Offer.count } }
      it { expect { create }.to change { flow.errors }.from({}).to eq(title: [:cannot_be_empty]) }
    end

    context 'no tags set' do
      let(:create) { flow.create_without_tags(title: 'test', tag_ids: []) }

      it { expect { create }.to change { flow.offer }.from(nil).to(instance_of(Offer)) }
      it { expect { create }.to change { Offer.count }.by(1) }
      it { expect { create }.not_to change { flow.errors }.from({}) }
    end

    describe 'offer' do
      before { create }
      subject(:offer) { flow.offer }

      it { expect(offer.user).to eq(performer) }
      it { expect(offer.tags).to eq([]) }
      it { is_expected.to be_persisted }
      it { is_expected.to be_valid }
    end
  end

  describe '#add_to_favorites' do
    before { flow.create(title: 'test', tag_ids: [tag.id]) }

    let(:add_to_favorites) { flow.add_to_favorites }

    it { expect { add_to_favorites }.to change { flow.offer.favorites.count }.from(0).to(1) }

    describe 'favorite' do
      before { add_to_favorites }
      subject(:favorite) { flow.offer.favorites.first }

      it { expect(favorite.user).to eq(performer) }
    end
  end

  describe '#like' do
    subject(:flow) { described_class.new(performer: performer, subject: offer) }

    let(:offer) { create_offer }
    let(:like) { flow.like }

    it { expect { like }.to change { Feedback.count }.by(1) }
    it { expect { like }.to change { offer.feedbacks.count }.from(0).to(1) }

    describe 'feedback' do
      before { like }
      subject(:feedback) { offer.feedbacks.first }

      it { is_expected.to be_positive }
    end
  end

  describe '#dislike' do
    subject(:flow) { described_class.new(performer: performer, subject: offer) }

    let(:offer) { create_offer }
    let(:dislike) { flow.dislike }

    it { expect { dislike }.to change { Feedback.count }.by(1) }
    it { expect { dislike }.to change { offer.feedbacks.count }.from(0).to(1) }

    describe 'feedback' do
      before { dislike }
      subject(:feedback) { offer.feedbacks.first }

      it { is_expected.not_to be_positive }
    end
  end

  describe '#subscribe' do
    subject(:flow) { described_class.new(performer: performer, subject: offer) }

    let(:offer) { create_offer }
    let(:subscribe) { flow.subscribe }

    it { expect { subscribe }.to change { Subscription.count }.by(1) }
    it { expect { subscribe }.to change { offer.subscriptions.count }.from(0).to(1) }

    describe 'subscription' do
      before { subscribe }
      subject(:subscription) { offer.subscriptions.first }

      it { expect(subscription.reload.user).to eq(performer) }
      it { expect(subscription.reload.query).to eq(offer.title) }
      it { expect(subscription.reload.tags).to eq(offer.tags) }
    end
  end

  describe '#hit' do
    subject(:flow) { described_class.new(performer: performer, subject: offer) }
    let(:offer) { create_offer }

    it { expect { flow.hit }.to change { offer.reload.hits_count }.by(1) }
  end

  describe '#send_message' do
    subject(:flow) { described_class.new(performer: performer, subject: offer) }

    let(:offer) { create_offer }
    let(:send_message) { flow.send_message('test message') }

    it { expect { send_message }.to change { Message.count }.by(1) }
    it { expect { send_message }.to change { offer.messages.count }.from(0).to(1) }

    context 'empty message' do
      let(:send_message) { flow.send_message('') }

      it { expect { send_message }.not_to change { Message.count } }
      it { expect { send_message }.not_to change { offer.messages.count } }
      it { expect { send_message }.to change { flow.flows.message.errors }.from({}).to(content: [:cannot_be_empty]) }
      it { expect { send_message }.to change { flow.errors }.from({}).to(message: {content: [:cannot_be_empty]}) }
    end

    describe 'message' do
      before { send_message }
      subject(:message) { offer.messages.first }

      it { expect(message.reload.user).to eq(performer) }
      it { expect(message.reload.content).to eq('test message') }
      it { expect(message.reload.parent).to eq(nil) }
    end
  end

  describe '#send_reply' do
    subject(:flow) { described_class.new(performer: performer, subject: offer) }

    let(:offer) { create_offer }
    let!(:parent_message) { described_class.new(performer: create_user, subject: offer).send_message('test message').flows.message.subject }
    let(:send_reply) { flow.send_reply(parent_id: parent_message.id, content: 'test submessage') }

    it { expect { send_reply }.to change { Message.count }.by(1) }
    it { expect { send_reply }.to change { offer.messages.count }.from(1).to(2) }

    describe 'message' do
      before { send_reply }
      subject(:message) { offer.messages.where.not(id: parent_message.id).first }

      it { expect(message.reload.user).to eq(performer) }
      it { expect(message.reload.content).to eq('test submessage') }
      it { expect(message.reload.parent).to eq(parent_message) }
    end
  end

  describe '#update' do
    subject(:flow) { described_class.new(performer: performer, subject: offer) }

    let(:offer) { create_offer }
    let(:new_tag) { create_tag }
    let(:update) { flow.update title: 'changed', tag_ids: [new_tag.id], user: create_user }

    it { expect { update }.to change { offer.reload.title }.to 'changed' }
    it { expect { update }.to change { offer.reload.tags(true).to_a }.to([new_tag]) }
    it { expect { update }.not_to change { offer.reload.user } }

    describe '#update_tags' do
      let(:update) { flow.update_tags title: 'changed', tag_ids: [new_tag.id], user: create_user }

      it { expect { update }.to change { offer.reload.tags(true).to_a }.to([new_tag]) }
      it { expect { update }.not_to change { offer.reload.title } }
      it { expect { update }.not_to change { offer.reload.user } }
    end
  end
end