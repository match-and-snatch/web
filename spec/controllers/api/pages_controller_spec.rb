require 'spec_helper'

describe Api::PagesController, type: :controller do
  describe 'GET#terms_of_service' do
    subject { get 'terms_of_service', format: :json }

    let!(:tos) { create(:tos_version, :published) }

    its(:status) { is_expected.to eq(200) }
    its(:body) { is_expected.to include 'success' }
  end
end
