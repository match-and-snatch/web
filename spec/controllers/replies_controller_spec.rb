describe RepliesController, type: :controller do
  let(:poster) { create(:user) }
  let(:commenter) { create(:user) }
  let(:_post) { create(:status_post, user: poster) }
  let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }
  let(:reply) { CommentManager.new(user: commenter, post: _post, parent: comment).create(message: 'reply') }

  before { SubscriptionManager.new(subscriber: commenter).subscribe_to(poster) }

  describe 'GET #show' do
    subject { get :show, params: {comment_id: comment.id, id: reply.id} }

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

  describe 'GET #confirm_make_visible' do
    subject { get :confirm_make_visible, params: {comment_id: comment.id, id: reply.id} }

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

  describe 'GET #confirm_hide' do
    subject { get :confirm_hide, params: {comment_id: comment.id, id: reply.id} }

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
