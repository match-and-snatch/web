require 'spec_helper'

describe Api::CommentsController, type: :controller do
  let(:poster) { create_user email: 'poster@gmail.com', api_token: 'poster_token' }
  let(:commenter) { create_user email: 'commenter@gmail.com', api_token: 'commenter_token' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }
  let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }
  let(:anybody_else) { create_user email: 'anybody@gmail.com', api_token: 'anybody_token' }

  describe 'GET #show' do
    subject { get 'show', id: comment.id, format: :json }

    before do
      SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
    end

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
        it { should be_success }
      end

      context 'as subscriber' do
        before do
          SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
        end
        let(:token) { commenter.api_token }
        it { should be_success }
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
        it { should be_success }
      end

      context 'as subscriber' do
        before do
          SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
        end
        let(:token) { commenter.api_token }
        it { should be_success }
      end
    end
  end

  describe 'PUT #update' do
    before { SubscriptionManager.new(subscriber: commenter).subscribe_to(poster) }
    subject(:perform_request) { put 'update', post_id: _post.id, id: comment.id, message: 'updated', format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { should be_success }

        specify do
          expect { perform_request }.to change { comment.reload.message }.to('updated')
        end
      end

      context 'as a post owner' do
        let(:token) { commenter.api_token }

        its(:status) { should eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end

  describe 'DELETE #destroy' do
    before { SubscriptionManager.new(subscriber: commenter).subscribe_to(poster) }
    let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }

    subject { delete 'destroy', post_id: _post.id, id: comment.id, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }
        it { should be_success }
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }
        its(:status) { should eq(200) }
      end
    end
  end

  describe 'PUT #make_visible' do
    before do
      SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
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

        it { should be_success }

        specify do
          expect { perform_request }.to change { comment.reload.hidden? }.to(false)
        end
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }

        its(:status) { should eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end

  describe 'PUT #hide' do
    before do
      SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
    end

    subject(:perform_request) { put 'hide', post_id: _post.id, id: comment.id, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(token) }

      context 'as comment owner' do
        let(:token) { commenter.api_token }

        it { should be_success }

        specify do
          expect { perform_request }.to change { comment.reload.hidden? }.to(true)
        end
      end

      context 'as a post owner' do
        let(:token) { poster.api_token }

        its(:status) { should eq(200) }
      end

      context 'as anybody else' do
        let(:token) { anybody_else.api_token }

        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end
end
