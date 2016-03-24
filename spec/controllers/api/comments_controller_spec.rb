require 'spec_helper'

describe Api::CommentsController, type: :controller do
  let(:poster) { create(:user) }
  let(:commenter) { create(:user) }
  let(:anybody_else) { create(:user) }
  let(:_post) { create(:status_post, user: poster) }
  let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }

  def subscribe
    SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
  end

  describe 'GET #show' do
    subject { get 'show', id: comment.id, format: :json }

    before { subscribe }

    before { sign_in_with_token(token) }

    context 'unauthorized access' do
      let(:token) { }
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      context 'as poster' do
        let(:token) { poster.api_token }

        it { is_expected.to be_success }
      end

      context 'as subscriber' do
        let(:token) { commenter.api_token }

        it { is_expected.to be_success }
      end
    end
  end

  describe 'GET #index' do
    subject { get 'index', post_id: _post.id, format: :json }

    before { sign_in_with_token(token) }

    context 'unauthorized access' do
      let(:token) { commenter.api_token }
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      context 'as poster' do
        let(:token) { poster.api_token }
        it { is_expected.to be_success }
      end

      context 'as subscriber' do
        before { subscribe }
        let(:token) { commenter.api_token }
        it { is_expected.to be_success }
      end
    end
  end

  describe 'POST #create' do
    subject { post 'create', post_id: _post.id, message: 'Comment', format: :json }

    before { sign_in_with_token(token) }

    context 'unauthorized access' do
      let(:token) { commenter.api_token }
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      context 'as poster' do
        let(:token) { poster.api_token }
        it { is_expected.to be_success }
      end

      context 'as subscriber' do
        before { subscribe }
        let(:token) { commenter.api_token }
        it { is_expected.to be_success }
      end
    end
  end

  describe 'PUT #update' do
    before { subscribe }
    subject(:perform_request) { put 'update', post_id: _post.id, id: comment.id, message: 'updated', format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { is_expected.to be_success }

        specify do
          expect { perform_request }.to change { comment.reload.message }.to('updated')
        end
      end

      context 'as a post owner' do
        let(:token) { commenter.api_token }

        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end

  describe 'DELETE #destroy' do
    before { subscribe }
    let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }

    subject { delete 'destroy', post_id: _post.id, id: comment.id, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }
        its(:status) { is_expected.to eq(200) }
      end
    end
  end

  describe 'PUT #make_visible' do
    before do
      subscribe
      CommentManager.new(user: poster, comment: comment).hide
    end

    subject(:perform_request) { put 'make_visible', post_id: _post.id, id: comment.id, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { is_expected.to be_success }

        specify do
          expect { perform_request }.to change { comment.reload.hidden? }.to(false)
        end
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }

        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end

  describe 'PUT #hide' do
    before { subscribe }

    subject(:perform_request) { put 'hide', post_id: _post.id, id: comment.id, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { is_expected.to be_success }

        specify do
          expect { perform_request }.to change { comment.reload.hidden? }.to(true)
        end
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }

        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end

  describe 'PUT #show_siblings' do
    subject { put 'show_siblings', id: comment.id, format: :json }

    before { subscribe }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }

        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end

  describe 'PUT #hide_siblings' do
    subject { put 'hide_siblings', id: comment.id, format: :json }

    before { subscribe }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }

        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end
end
