require 'spec_helper'

describe CommentsController, type: :controller do
  let(:poster) { create(:user) }
  let(:commenter) { create(:user) }
  let(:_post) { create(:status_post, user: poster) }
  let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }

  def subscribe
    SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
  end

  describe 'GET #index' do
    subject { get 'index', post_id: _post.id }

    context 'unauthorized access' do
      before { sign_in commenter }
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as poster' do
        before { sign_in poster }
        it { is_expected.to be_success }
      end

      context 'as subscriber' do
        before { subscribe }
        before { sign_in commenter }
        it { is_expected.to be_success }
      end
    end
  end

  describe 'POST #create' do
    subject { post 'create', post_id: _post.id, message: 'Reply' }

    context 'unauthorized access' do
      before { sign_in commenter }
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as poster' do
        before { sign_in poster }
        it { is_expected.to be_success }
      end

      context 'as subscriber' do
        before do
          subscribe
          sign_in commenter
        end
        it { is_expected.to be_success }
      end
    end
  end

  describe 'GET #edit' do
    before { subscribe }
    subject { get 'edit', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'GET #show' do
    before { subscribe }
    subject { get 'show', id: comment.id }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'GET #full_text' do
    before { subscribe }
    subject { get 'full_text', id: comment.id }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'PUT #update' do
    before { subscribe }
    subject(:perform_request) { put 'update', post_id: _post.id, id: comment.id, message: 'updated' }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }

        specify do
          expect { perform_request }.to change { comment.reload.message }.to('updated')
        end
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'GET #confirm_make_visible' do
    before { subscribe }

    subject(:perform_request) { get 'confirm_make_visible', id: comment.id }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'PUT #make_visible' do
    before do
      subscribe
      CommentManager.new(user: poster, comment: comment).hide
    end

    subject(:perform_request) { put 'make_visible', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }

        specify do
          expect { perform_request }.to change { comment.reload.hidden? }.to(false)
        end
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'GET #confirm_hide' do
    before { subscribe }

    subject(:perform_request) { get 'confirm_hide', id: comment.id }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'PUT #hide' do
    before { subscribe }

    subject(:perform_request) { put 'hide', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }

        specify do
          expect { perform_request }.to change { comment.reload.hidden? }.to(true)
        end
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'PUT #show_siblings' do
    subject { put 'show_siblings', id: comment.id }

    before { subscribe }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'PUT #hide_siblings' do
    subject { put 'hide_siblings', id: comment.id }

    before { subscribe }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'DELETE #destroy' do
    before { subscribe }
    let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }
    subject { delete 'destroy', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { is_expected.to be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end
end

