require 'spec_helper'

describe Users::DirectoriesController, type: :controller do
  describe 'GET show' do
    context 'as HTML' do
      subject(:perform_request) { get 'show', id: 'A' }

      it { should be_success }
    end

    context 'as JSON' do
      subject(:perform_request) { get 'show', id: 'A', format: :json }

      it { should be_success }
      its(:body) { should match_regex /success/ }
    end
  end
end
