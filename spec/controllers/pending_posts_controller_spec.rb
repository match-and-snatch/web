require 'spec_helper'

describe PendingPostsController, type: :controller do
  before { sign_in }

  describe 'PUT #update' do
    subject { put 'update', {message: 'test'} }
    it { should be_success }
  end
end