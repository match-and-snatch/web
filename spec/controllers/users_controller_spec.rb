require 'spec_helper'

describe ::UsersController, type: :controller do
  describe 'POST #create' do
    context 'nothing passed' do
      subject { post 'create' }

      it { should be_success }
      its(:body) { should match_regex /failed/ }
    end

    context 'proper params' do
      subject { post 'create', email: 'szinin@gmail.com',
                               first_name: 'sergei',
                               last_name: 'zinin',
                               password: 'qwerty',
                               password_confirmation: 'qwerty' }

      it { should be_success }
      its(:body) { should match_regex /redirect/ }
    end
  end

  describe 'GET #show' do
    let!(:owner)  { create_profile email: 'owner@gmail.com' }
    let(:visitor) { create_user email: 'visitor@gmail.com' }
    subject { get 'show', id: owner.slug  }

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
      it{ should render_template('owner_view') }
    end

    context 'unauthorized access' do
      it { should be_success }
      it{ should render_template('public_show') }
    end

    context 'when profile public' do
      let!(:owner) { create_public_profile email: 'owner_with_public@gmail.com' }
      it { should be_success }
      it{ should render_template('show') }
    end
  end

  let(:profile) { create_profile email: 'profile@gmail.com' }
  describe 'PUT #update_name' do
    subject { put 'update_name', id: profile.slug, profile_name: 'anotherName'}

    context 'authorized access' do
      before { sign_in profile }
      its(:status) { should == 200 }
      its(:body) { should match_regex /success/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'PUT #update_cost' do
    subject { put 'update_cost', id: "anything", cost: 10}

    context 'authorized access' do
      before { sign_in profile }
      its(:status) { should == 200 }
      its(:body) { should match_regex /reload/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'PUT #update_contacts_info' do
    subject { put 'update_contacts_info', contacts_info_data_params }

    context 'authorized access' do
      before { sign_in profile }
      its(:status) { should == 200 }
      its(:body) { should match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'PUT #update_cover_picture_position' do
    subject { put 'update_cover_picture_position', id: 'anything', cover_picture_position: 100 }

    context 'authorized access' do
      before { sign_in profile }
      its(:status) { should == 200 }
      its(:body) { should match_regex /success/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'PUT #update_cover_picture' do
    subject { put 'update_cover_picture', id: profile.id, transloadit: cover_picture_data_params.to_json }

    context 'authorized access' do
      before { sign_in profile }
      its(:status) { should == 200 }
      its(:body) { should match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'GET #edit_welcome_media' do
    let!(:owner)  { create_profile email: 'owner@gmail.com' }
    subject { get 'edit_welcome_media', id: owner.slug }

    context 'authorized access' do
      before { sign_in owner }
      it { should be_success }
      its(:body) { should match_regex /success/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'PUT #update_welcome_media' do
    context 'with welcome video' do
      subject { put 'update_welcome_media', id: profile.id, transloadit: welcome_video_data_params.to_json }

      context 'authorized access' do
        before { sign_in profile }
        its(:status) { should == 200 }
        its(:body) { should match_regex /replace/ }
      end

      context 'unauthorized access' do
        its(:status) { should == 401 }
      end
    end

    context 'with welcome audio' do
      subject { put 'update_welcome_media', id: profile.id, transloadit: welcome_audio_data_params.to_json }

      context 'authorized access' do
        before { sign_in profile }
        its(:status) { should == 200 }
        its(:body) { should match_regex /replace/ }
      end

      context 'unauthorized access' do
        its(:status) { should == 401 }
      end
    end
  end

  describe 'DELETE #remove_welcome_media' do
    subject { delete 'remove_welcome_media', id: profile.id }

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end

    context 'authorized access' do
      before { sign_in profile }
      it { should be_success }
      its(:body) { should match_regex /replace/ }
    end
  end

  describe 'PUT #update_profile_picture' do
    subject { put 'update_profile_picture', id: profile.id, transloadit: profile_picture_data_params.to_json }

    context 'authorized access' do
      before { sign_in profile }
      its(:status) { should == 200 }
      its(:body) { should match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'PUT #update_profile_picture' do
    subject { put 'update_profile_picture', id: profile.id, transloadit: profile_picture_data_params.to_json }

    context 'authorized access' do
      before { sign_in profile }
      its(:status) { should == 200 }
      its(:body) { should match_regex /replace/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end

  describe 'GET #search' do
    let!(:profile1) { create_profile profile_name: 'serg', profile_picture_url: 'set', is_profile_owner: true }
    subject(:perform_request) { get 'search', q: 'serg' }

    context 'user is hidden' do
      before { perform_request }

      specify { expect(assigns('users')).to eq [] }
    end

    context 'user is not hidden' do
      before do
        UserProfileManager.new(profile1).toggle
        perform_request
      end

      specify { expect(assigns('users')).to eq [profile1] }
    end

    its(:status) { should == 200 }
    its(:body) { should match_regex /replace/ }
  end
end
