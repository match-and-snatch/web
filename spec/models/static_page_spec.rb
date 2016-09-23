RSpec.describe StaticPage do
  subject { StaticPage.new(attributes) }

  let(:attributes) { {slug: slug, content: content} }
  let(:slug) { 'test' }
  let(:content) { 'set' }

  it { is_expected.to be_valid }

  context 'without slug' do
    let(:slug) { ' ' }
    it { is_expected.not_to be_valid }
  end

  context 'slug has already taken' do
    before { described_class.create!(attributes) }
    it { is_expected.not_to be_valid }
  end

  context 'without content' do
    let(:content) { ' ' }
    it { is_expected.not_to be_valid }
  end
end
