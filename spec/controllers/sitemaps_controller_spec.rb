require 'spec_helper'

describe SitemapsController, type: :controller do
  describe 'GET #show' do
    subject { get 'show', format: :xml }
    it { should be_success }
  end

  describe 'GET #sitemap_mobile' do
    subject { get 'sitemap_mobile', format: :xml }
    it { should be_success }
  end
end
