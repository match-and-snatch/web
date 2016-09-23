RSpec.describe Dashboard::Admin::StaticPagesController, type: :controller do
  let(:json_response) { JSON.parse(subject.body) }
  let(:static_page) { StaticPage.create!(slug: slug, content: 'set') }
  let(:slug) { 'test' }

  describe 'GET #index' do
    before { get 'index' }

    it { is_expected.to be_success }
  end

  describe 'GET #new' do
  end

  describe 'POST #create' do
    subject(:perform_request) { post 'create', slug: slug, content: 'set' }

    it 'creates a new static page' do
      expect { perform_request }.to create_record(StaticPage).matching(slug: 'test', content: 'set')
    end

    it 'reloads the page with a message' do
      expect(json_response['status']).to eq('reload')
      expect(json_response['notice']).to include('has been created')
    end
  end

  describe 'GET #edit' do
    subject { get 'edit', id: static_page.id }

    it 'renders the popup' do
      expect(json_response['status']).to eq('success')
      expect(json_response['popup']).to be_present
    end
  end

  describe 'GET #update' do
    subject(:perform_request) { patch 'update', id: static_page.id, slug: 'updated_slug', content: 'updated_content' }

    it 'updates the slug' do
      expect { perform_request }.to change { static_page.reload.slug }.to('updated_slug')
    end

    it 'updates the content' do
      expect { perform_request }.to change { static_page.reload.content }.to('updated_content')
    end

    it 'reloads the page with a message' do
      expect(json_response['status']).to eq('reload')
      expect(json_response['notice']).to include('has been updated')
    end
  end

  describe 'DELETE #destroy' do
    subject(:perform_request) { delete 'destroy', id: static_page.id }

    it 'removes the record' # Add matcher "remove_record", see "create_record" sample

    it 'reloads the page with a message' do
      expect(json_response['status']).to eq('reload')
      expect(json_response['notice']).to include('has been removed')
    end
  end
end

