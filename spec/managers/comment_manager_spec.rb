require 'spec_helper'

describe CommentManager do
  subject(:manager) { described_class.new(user: user, post: post) }

  let(:user) { create(:user) }
  let(:post) { create(:status_post, user: user, message: 'Test') }

  describe '#create' do
    it { expect { manager.create(message: 'comment') }.to create_record(Comment).matching(message: 'comment') }
    it { expect { manager.create(message: 'comment') }.to create_event(:comment_created).with_user(user).including_data(message: 'comment', post_id: post.id, post_user_id: user.id) }

    context 'with tags in message' do
      it { expect { manager.create(message: 'comment <img src="image">') }.to create_record(Comment).matching(message: 'comment') }

      context 'with link' do
        it { expect { manager.create(message: 'comment <a href="http://connectpal.com">Connectpal.com</a>') }.to create_record(Comment).matching(message: 'comment Connectpal.com') }
      end
    end

    context 'with mentions' do
      let(:mentioned_user) { create(:user) }
      let(:mentions) { { mentioned_user.id => mentioned_user.name } }

      it { expect(manager.create(message: 'comment', mentions: mentions).mentions).to eq(mentions) }
      it { expect { manager.create(message: 'comment', mentions: mentions) }.to deliver_email(to: mentioned_user.email, subject: /You were mentioned/) }
    end
  end

  describe '#update' do
    subject(:manager) { described_class.new(user: user, comment: comment) }

    let(:comment) { described_class.new(user: user, post: post).create(message: 'comment') }

    it { expect { manager.update(message: 'edited') }.to change { comment.message }.from('comment').to('edited')  }
    it { expect { manager.update(message: 'edited') }.to create_event(:comment_updated).with_user(user).including_data(message: 'edited', post_id: post.id, post_user_id: user.id) }

    context 'with tags in message' do
      it { expect { manager.update(message: 'edited <img src="image">') }.to change { comment.message }.from('comment').to('edited') }

      context 'with link' do
        it { expect { manager.update(message: 'edited <a href="http://connectpal.com">Connectpal.com</a>') }.to change { comment.message }.from('comment').to('edited Connectpal.com') }
      end
    end

    context 'with mentions' do
      let(:mentioned_user) { create(:user) }
      let(:mentions) { { mentioned_user.id => mentioned_user.name } }

      it { expect { manager.update(message: 'edited', mentions: mentions) }.to change { comment.mentions }.from({}).to(mentions) }
    end
  end

  describe '#hide_siblings' do
    subject(:manager) { described_class.new(user: user, comment: comment) }

    let(:commenter) { create(:user) }
    let(:comment) { described_class.new(user: commenter, post: post).create(message: 'comment') }

    before { SubscriptionManager.new(subscriber: commenter).subscribe_to(user) }

    it { expect { manager.hide_siblings }.to change { comment.reload.hidden? }.from(false).to(true) }
    it { expect { manager.hide_siblings }.to create_record(CommentIgnore).matching(user_id: user.id, commenter_id: commenter.id, enabled: true) }

    context 'hide more than once' do
      before do
        manager.hide_siblings
        manager.show_siblings
      end

      it { expect { manager.hide_siblings }.to change { comment.reload.hidden? }.from(false).to(true) }
      it { expect { manager.hide_siblings }.not_to create_record(CommentIgnore) }
      it { expect { manager.hide_siblings }.to change { user.comment_ignores.first.enabled? }.from(false).to(true) }
    end
  end

  describe '#show_siblings' do
    subject(:manager) { described_class.new(user: user, comment: comment) }

    let(:commenter) { create(:user) }
    let(:comment) { described_class.new(user: commenter, post: post).create(message: 'comment') }

    before { SubscriptionManager.new(subscriber: commenter).subscribe_to(user) }

    context 'without hidden comments' do
      it { expect { manager.show_siblings }.not_to change { comment.reload.hidden? }.from(false) }
    end

    context 'with hidden comments' do
      before { manager.hide_siblings }

      it { expect { manager.show_siblings }.to change { comment.reload.hidden? }.from(true).to(false) }
      it { expect { manager.show_siblings }.to change { user.comment_ignores.first.enabled? }.from(true).to(false) }
    end
  end
end
