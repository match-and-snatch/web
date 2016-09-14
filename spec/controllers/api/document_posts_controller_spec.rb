RSpec.describe Api::DocumentPostsController, type: :controller do
  let(:owner) { create(:user, :profile_owner, email: 'owner@gmail.com') }

  describe 'GET #new' do
    subject { get :new, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #cancel' do
    subject { delete :cancel, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { is_expected.to be_success }
    end
  end

  describe 'POST #create' do
    subject { post :create, params: {title: 'document', message: 'post'}, format: :json }

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      let!(:pending_document) { create(:document, user: owner) }

      it { is_expected.to be_success }
    end

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end
  end
end
