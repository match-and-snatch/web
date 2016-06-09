require 'spec_helper'

describe Api::ProfileInfosController, type: :controller do
  let(:user) { create(:user) }

  describe 'POST #create_profile' do
    subject(:perform_request) { post 'create_profile', cost: 10, profile_name: 'test', format: :json }

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }

      context 'already have profile created' do
        pending 'shows error'
      end
    end

    context 'unauthorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end
  end

  describe 'GET #settings' do
    subject { get 'settings', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #update_bank_account_data' do
    subject { put 'update_bank_account_data', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #enable_rss' do
    subject { put 'enable_rss', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_rss' do
    subject { put 'disable_rss', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #enable_downloads' do
    subject { put 'enable_downloads', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_downloads' do
    subject { put 'disable_downloads', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #enable_itunes' do
    subject { put 'enable_itunes', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_itunes' do
    subject { put 'disable_itunes', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #enable_vacation_mode' do
    subject { put 'enable_vacation_mode', vacation_message: 'test', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_vacation_mode' do
    subject { post 'disable_vacation_mode', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #update_welcome_media' do
    context 'with welcome video' do
      subject { put 'update_welcome_media', transloadit: welcome_video_data_params.to_json, format: :json }

      context 'authorized access' do
        before { sign_in_with_token(user.api_token) }

        it { should be_success }
      end

      context 'unauthorized access' do
        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end

    context 'with welcome audio' do
      subject { put 'update_welcome_media', transloadit: welcome_audio_data_params.to_json, format: :json }

      context 'authorized access' do
        before { sign_in_with_token(user.api_token) }

        it { should be_success }
      end

      context 'unauthorized access' do
        it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
      end
    end
  end

  describe 'DELETE #remove_welcome_media' do
    subject { delete 'remove_welcome_media', format: :json }

    context 'unauthorized access' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized access' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #enable_message_notifications' do
    subject { put 'enable_message_notifications', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end

  describe 'PUT #disable_message_notifications' do
    subject { put 'disable_message_notifications', format: :json }

    context 'not authorized' do
      it { expect(JSON.parse(subject.body)).to include({'status'=>401}) }
    end

    context 'authorized' do
      before { sign_in_with_token(user.api_token) }

      it { should be_success }
    end
  end
end
