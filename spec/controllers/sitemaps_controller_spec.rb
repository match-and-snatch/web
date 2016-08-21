describe SitemapsController, type: :controller do
  describe 'GET #show' do
    subject { get :show, params: {format: :xml} }
    it { is_expected.to be_success }
  end

  describe 'GET #sitemap_mobile' do
    subject { get :sitemap_mobile, params: {format: :xml} }
    it { is_expected.to be_success }
  end
end
