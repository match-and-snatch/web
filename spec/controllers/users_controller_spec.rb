require 'spec_helper'

describe UsersController do
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
      its(:status) { should == 200 }
      it{ should render_template('owner_view') }
    end

    context 'unauthorized access' do
      its(:status) { should == 200 }
      it{ should render_template('public_show') }
    end

    context 'when profile public' do
      let!(:owner) { create_public_profile email: 'owner_with_public@gmail.com' }
      its(:status) { should == 200 }
      it{ should render_template('show') }
    end
  end

  describe 'PUT #update_name' do
    let(:owner) { create_profile email: 'owner@gmail.com' }
    subject { put 'update_name', id: owner.slug, profile_name: 'anotherName'}

    context 'authorized access' do
      before { sign_in owner }
      its(:status){ should == 200 }
      its(:body){ should match_regex /success/ }
    end

    context 'unauthorized access' do
      its(:status) { should == 401 }
    end
  end
end
