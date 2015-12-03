require 'spec_helper'

describe Comment do
  describe '#user_picture_url' do
    let(:poster) { create(:user, :profile_owner, email: 'poster@gmail.com') }
    let(:commenter) { create(:user, email: 'commenter@gmail.com') }
    let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }

    before do
      SubscriptionManager.new(subscriber: commenter).subscribe_to(poster)
    end

    context 'comment from subscriber' do
      let(:comment) { CommentManager.new(user: commenter, post: _post).create(message: 'test') }

      it { expect(comment.user_picture_url).to eq(commenter.small_account_picture_url) }
    end

    context 'comment from profile owner' do
      let(:comment) { CommentManager.new(user: poster, post: _post).create(message: 'test') }

      it { expect(comment.user_picture_url).to eq(poster.small_profile_picture_url) }
    end
  end
end
