require 'spec_helper'

describe CommentFlow do
  subject(:flow) { described_class.new(performer: performer) }

  let(:performer) { create_user }
  let(:comment) {}
  let(:post) { PostManager.new(user: create_user(email: 'poster@test.ru')).create_status_post(message: 'test') }

  its(:comment) { is_expected.to be_nil }
  its(:subject) { is_expected.to be_nil }
  its(:result) { is_expected.to be_nil }

  describe '#create' do
    subject(:create) { flow.create(post: post, message: 'comment test') }

    it do
      expect { create }.to create_record(Comment).once.matching(
                              post_id: post.id,
                              post_user_id: post.user_id,
                              message: 'comment test',
                              user_id: performer.id)
    end

    its(:result) { is_expected.to be_a Comment }

    describe 'notifications' do
      subject(:create) { flow.create(post: post, message: 'test', mentions: {mentioned_user.id => 'you'}) }
      let(:mentioned_user) { create_user email: 'mentioned@email.com' }

      it do
        expect { create }.to deliver_email(to: mentioned_user.email, subject: /You were mentioned/)
      end
    end

    describe 'events' do
      it do
        expect { create }.to create_event(:comment_created).including_data(message: 'comment test')
      end
    end
  end

  describe '#hide' do
    subject(:hide) { base_flow.hide }

    let(:base_flow) { flow.create(post: post, message: 'comment test') }
    let(:comment) { base_flow.comment }

    it do
      expect { hide }.to change { comment.reload.hidden }.to(true)
    end

    it do
      expect { hide }.to create_event(:comment_hidden).with_subject(comment)
    end
  end

  describe '#show' do
    subject(:show) { base_flow.show }

    let(:base_flow) { flow.create(post: post, message: 'comment test').hide }
    let(:comment) { base_flow.comment }

    it do
      expect { show }.to change { comment.reload.hidden }.to(false)
    end

    it do
      expect { show }.to create_event(:comment_shown).with_subject(comment)
    end
  end

  describe '#toggle_like' do
    subject(:toggle_like) { base_flow.toggle_like }

    let(:base_flow) { flow.create(post: post, message: 'comment test') }
    let(:comment) { base_flow.comment }

    it do
      expect { toggle_like }.to create_record(Like).once.matching(
                                  comment_id: comment.id,
                                  likable_id: comment.id,
                                  likable_type: comment.class.name,
                                  target_user: comment.user,
                                  user: performer)
    end

    its(:result) { is_expected.to be_a Like }

    context 'liked' do
      before { base_flow.toggle_like }

      it do
        expect { toggle_like }.to change { comment.likes.count }.by(-1)
      end
    end
  end
end