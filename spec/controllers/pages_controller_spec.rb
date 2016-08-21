describe PagesController, type: :controller do
  describe 'GET #about' do
    subject { get 'about' }
    it { is_expected.to be_success }
  end

  describe 'GET #pricing' do
    subject { get 'pricing' }
    it { is_expected.to be_success }
  end

  describe 'GET #contact_us' do
    subject { get 'contact_us' }
    it { is_expected.to be_success }
  end

  describe 'GET #terms_of_service' do
    subject { get 'terms_of_service' }
    it { is_expected.to be_success }
  end

  describe 'GET #privacy_policy' do
    subject { get 'privacy_policy' }
    it { is_expected.to be_success }
  end
end
