require 'spec_helper'

describe User do
  describe '.create' do
    context 'profile owner' do
      it 'assigns slug' do
        expect(create_user(first_name: 'slava', last_name: 'popov', is_profile_owner: true).slug).to eq('slava-popov')
      end

      it 'generates uniq slug' do
        create_user(first_name: 'slava', last_name: 'popov', email: 'e@m.il', is_profile_owner: true)
        expect(create_user(first_name: 'slava', last_name: 'popov', email: 'e2@m.il', is_profile_owner: true).slug).to eq('slava-popov-1')
        expect(create_user(first_name: 'slava', last_name: 'popov', email: 'e3@m.il', is_profile_owner: true).slug).to eq('slava-popov-2')
      end
    end

    context 'subscriber' do
      it 'does not assign slug' do
        expect(create_user(first_name: 'slava', last_name: 'popov', is_profile_owner: false).slug).to eq(nil)
      end
    end
  end

  describe '#complete_profile?' do
    subject { described_class.new(is_profile_owner: true, profile_name: profile_name, slug: slug, cost: cost, holder_name: holder_name, routing_number: routing_number, account_number: account_number).complete_profile? }

    let(:profile_name) { 'Serezha' }
    let(:slug) { 'sergei' }
    let(:cost) { 1 }
    let(:holder_name) { 'sergei' }
    let(:routing_number) { '123' }
    let(:account_number) { '12345' }

    it { should eq(true) }

    context 'empty profile name' do
      let(:profile_name) { ' ' }
      it { should eq(false) }
    end

    context 'empty slug' do
      let(:slug) {}
      it { should eq(false) }
    end

    context 'empty cost' do
      let(:cost) {}
      it { should eq(false) }
    end

    context 'empty holder_name' do
      let(:holder_name) {}
      it { should eq(true) }
    end

    context 'empty routing_number' do
      let(:routing_number) {}
      it { should eq(true) }
    end

    context 'empty account_number' do
      let(:account_number) {}
      it { should eq(true) }
    end
  end

  describe '#admin?' do
    context 'admins' do
      subject { User.new is_admin: true }
      its(:admin?) { should eq(true) }

      context 'from config' do
        subject { User.new email: 'szinin@gmail.com' }
        its(:admin?) { should eq(true) }
      end
    end

    context 'non admins' do
      its(:is_admin?) { should eq(false) }
      its(:admin?) { should eq(false) }
    end
  end

  describe '#subscribed_to?' do
    subject { user.subscribed_to?(target_user) }

    let(:user) { create_user }
    let(:target_user) { create_profile email: 'target@user.com' }

    context 'with' do
      let!(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

      context 'active subscription' do
        it { should eq(true) }
      end

      context 'rejected subscription' do
        before do
          StripeMock.start
          StripeMock.prepare_card_error(:card_declined)
          PaymentManager.new.pay_for(subscription)
        end
        after { StripeMock.stop }

        it { should eq(false) }
      end

      context 'removed subscription' do
        before do
          SubscriptionManager.new(subscriber: user, subscription: subscription).unsubscribe
        end

        it { should eq(true) }
      end

      context 'expired subscription' do
        let!(:subscription) do
          Timecop.freeze 32.days.ago do
            SubscriptionManager.new(subscriber: user).subscribe_to(target_user)
          end
        end

        before do
          SubscriptionManager.new(subscriber: user, subscription: subscription).unsubscribe
        end

        it { should eq(false) }
      end
    end

    context 'without subscription' do
      it { should eq(false) }
    end
  end

  describe '.search_by_text_fields' do
    let!(:matching_by_full_name) { create_user first_name: 'sergei', last_name: 'zinin' }
    let!(:matching_by_profile_name) do
      create_user(first_name: 'another', last_name: 'one', email: 'another@email.com').tap do |user|
        UserProfileManager.new(user).update_profile_name('serge')
      end
    end
    let!(:not_mathing) { create_user first_name: 'slava', last_name: 'popov', email: 'slava@gmail.com' }

    specify do
      expect(described_class.search_by_text_fields('sergei')).to eq [matching_by_full_name, matching_by_profile_name]
    end
  end

  describe '#welcome_audio' do
    subject(:user) { create_user }

    its(:welcome_audio) { should be_nil }

    context 'with welcome audio' do
      let(:welcome_audio_data) { JSON.parse(welcome_audio_data_params['transloadit']) }
      let(:welcome_audio) { UploadManager.new(user).create_audio(welcome_audio_data).first }

      its(:welcome_audio) { should eq(welcome_audio) }
    end
  end

  describe 'welcome_video' do
    subject(:user) { create_user }

    its(:welcome_video) { should be_nil }

    context 'with welcome video' do
      let(:welcome_video_data) { JSON.parse(welcome_video_data_params['transloadit']) }
      let(:welcome_video) { UploadManager.new(user).create_video(welcome_video_data) }

      its(:welcome_video) { should eq(welcome_video) }
    end
  end
end
