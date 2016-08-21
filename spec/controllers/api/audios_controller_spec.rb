describe Api::AudiosController, type: :controller do
  let(:owner) { create(:user, :profile_owner, email: 'owner@gmail.com') }

  describe 'POST #create' do
    subject { post :create, params: {transloadit: transloadit_audio_data_params.to_json}, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { is_expected.to be_success }
    end
  end

  describe 'POST #reorder' do
    subject { get :reorder, params: {ids: [1, 2, 3]}, format: :json }

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      its(:status) { is_expected.to eq(200) }
    end

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end
  end

  describe 'DELETE #destroy' do
    let(:audio_upload) { create(:audio, user: owner) }

    subject { delete :destroy, params: {id: audio_upload.id}, format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token owner.api_token }

      it { is_expected.to be_success }
    end
  end
end
