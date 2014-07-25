require 'spec_helper'

describe CommentsController, type: :controller do
  let(:poster) { create_user email: 'poster@gmail.com' }
  let(:commenter) { create_user email: 'commenter@gmail.com' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }
  let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }

  describe 'GET #index' do
    subject { get 'index', post_id: _post.id }

    context 'unauthorized access' do
      before { sign_in commenter }
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as poster' do
        before { sign_in poster }
        it { should be_success }
      end

      context 'as subscriber' do
        before { SubscriptionManager.new(commenter).subscribe_to(poster) }
        before { sign_in commenter }
        it { should be_success }
      end
    end
  end

  describe 'POST #create' do
    subject { post 'create', post_id: _post.id, message: 'Reply' }

    context 'unauthorized access' do
      before { sign_in commenter }
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as poster' do
        before { sign_in poster }
        it { should be_success }
      end

      context 'as subscriber' do
        before { SubscriptionManager.new(commenter).subscribe_to(poster) }
        before { sign_in commenter }
        it { should be_success }
      end
    end
  end

  describe 'GET #edit' do
    before { SubscriptionManager.new(commenter).subscribe_to(poster) }
    subject { get 'edit', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { should be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { should == 200 }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { should == 401 }
      end
    end
  end

  describe 'PUT #update' do
    before { SubscriptionManager.new(commenter).subscribe_to(poster) }
    subject(:perform_request) { put 'update', post_id: _post.id, id: comment.id, message: 'updated' }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { should be_success }

        specify do
          expect { perform_request }.to change { comment.reload.message }.to('updated')
        end
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { should == 200 }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { should == 401 }
      end
    end
  end

  describe 'PUT #make_visible' do
    before do
      SubscriptionManager.new(commenter).subscribe_to(poster)
      CommentManager.new(comment: comment).hide
    end

    subject(:perform_request) { put 'make_visible', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { should be_success }

        specify do
          expect { perform_request }.to change { comment.reload.hidden? }.to(false)
        end
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { should == 200 }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { should == 401 }
      end
    end
  end

  describe 'PUT #hide' do
    before do
      SubscriptionManager.new(commenter).subscribe_to(poster)
    end

    subject(:perform_request) { put 'hide', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { should be_success }

        specify do
          expect { perform_request }.to change { comment.reload.hidden? }.to(true)
        end
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { should == 200 }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { should == 401 }
      end
    end
  end

  describe 'DELETE #destroy' do
    before { SubscriptionManager.new(commenter).subscribe_to(poster) }
    let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }
    subject { delete 'destroy', post_id: _post.id, id: comment.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      context 'as comment owner' do
        before { sign_in commenter }
        it { should be_success }
      end

      context 'as a post owner' do
        before { sign_in poster }
        its(:status) { should == 200 }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { should == 401 }
      end
    end
  end
end

