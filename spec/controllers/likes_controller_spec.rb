require 'spec_helper'

describe LikesController do
  let(:poster){ create_user email: 'poster@gmail.com' }
  let(:visitor) { create_user email: 'commenter@gmail.com' }
  let(:_post) { PostManager.new(user: poster).create_status_post(message: 'some post') }

  describe 'POST #create' do
    subject { post 'create', post_id: _post.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
        before { sign_in visitor }
        its(:body) { should match_regex /success/ }
        its(:status) { should == 200 }
    end
  end
end
