require 'spec_helper'

describe User do
  describe '.create' do
    context 'profile owner' do
      it 'assigns slug' do
        expect(create_user(first_name: 'slava', last_name: 'popov', is_profile_owner: true).slug).to eq('slavapopov')
      end

      it 'generates uniq slug' do
        create_user(first_name: 'slava', last_name: 'popov', email: 'e@m.il', is_profile_owner: true)
        expect(create_user(first_name: 'slava', last_name: 'popov', email: 'e2@m.il', is_profile_owner: true).slug).to eq('slavapopov-1')
        expect(create_user(first_name: 'slava', last_name: 'popov', email: 'e3@m.il', is_profile_owner: true).slug).to eq('slavapopov-2')
      end
    end

    context 'subscriber' do
      it 'does not assign slug' do
        expect(create_user(first_name: 'slava', last_name: 'popov', is_profile_owner: false).slug).to eq(nil)
      end
    end
  end

  describe '#denormalize_last_post_created_at!' do
    let!(:user) { create_user }

    context 'time provided' do
      let(:time) { 4.days.ago }

      specify do
        expect { user.denormalize_last_post_created_at!(time) }.to change { user.reload.last_post_created_at }.to(time)
      end
    end

    context 'no posts' do
      specify do
        expect { user.denormalize_last_post_created_at! }.not_to change { user.reload.last_post_created_at }
      end
    end

    context 'with posts' do
      let!(:post) { PostManager.new(user: user).create_status_post(message: 'test') }

      before do
        user.update!(last_post_created_at: nil)
      end

      specify do
        expect { user.denormalize_last_post_created_at! }.to change { user.reload.last_post_created_at }.to(post.created_at)
      end
    end
  end

  describe '#generate_api_token!' do
    subject(:user) { create_user }

    it do
      expect { user.generate_api_token! }.to change { user.reload.api_token }.from(nil)
    end

    context 'already generated' do
      before { user.generate_api_token! }

      it do
        expect { user.generate_api_token! }.not_to change { user.reload.api_token }
      end
    end
  end

  describe '#regenerate_api_token!' do
    subject(:user) { create_user }

    it do
      expect { user.regenerate_api_token! }.to change { user.reload.api_token }.from(nil)
    end

    context 'already generated' do
      before { user.generate_api_token! }

      it do
        expect { user.regenerate_api_token! }.to change { user.reload.api_token }
      end
    end
  end

  describe '.top' do
    subject { described_class.top }

    let(:top_user) do
      create_user(is_profile_owner: true).tap do |user|
        user.create_top_profile!
      end
    end

    let(:non_profile_owner) do
      create_user(is_profile_owner: false).tap do |user|
        user.create_top_profile!
      end
    end

    let(:non_top_user) { create_user is_profile_owner: true }

    it { is_expected.to include(top_user) }
    it { is_expected.not_to include(non_top_user) }
    it { is_expected.not_to include(non_profile_owner) }

    describe 'ordering' do
      let!(:middle_user) do
        create_user(is_profile_owner: true, email: 'middle@middle.com').tap do |user|
          user.create_top_profile! position: 1
        end
      end

      let!(:top_user) do
        create_user(is_profile_owner: true, email: 'top@top.com').tap do |user|
          user.create_top_profile! position: 0
        end
      end

      let!(:bottom_user) do
        create_user(is_profile_owner: true, email: 'bottom@bottom.com').tap do |user|
          user.create_top_profile! position: 2
        end
      end

      it { is_expected.to eq([top_user, middle_user, bottom_user]) }
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

        context 'with uppercase letters' do
          subject { User.new email: 'Szinin@gmail.com' }
          its(:admin?) { should eq(true) }
        end
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
          PaymentManager.new(user: user).pay_for(subscription)
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
      expect(described_class.search_by_text_fields('sergei')).to eq [matching_by_profile_name, matching_by_full_name]
    end
  end

  describe '#welcome_audio' do
    subject(:user) { create_user }

    its(:welcome_audio) { should be_nil }

    context 'with welcome audio' do
      let(:welcome_audio_data) { welcome_audio_data_params }
      let(:welcome_audio) { UploadManager.new(user).create_audio(welcome_audio_data).first }

      its(:welcome_audio) { should eq(welcome_audio) }
    end
  end

  describe '#welcome_video' do
    subject(:user) { create_user }

    its(:welcome_video) { should be_nil }

    context 'with welcome video' do
      let(:welcome_video_data) { welcome_video_data_params }
      let(:welcome_video) { UploadManager.new(user).create_video(welcome_video_data) }

      its(:welcome_video) { should eq(welcome_video) }
    end
  end

  describe '#unread_messages_count' do
    let(:user) { create_user }
    let(:friend) { create_user email: 'sender@gmail.com' }
    let(:dialogue) { MessagesManager.new(user: user).create(target_user: friend, message: 'test').dialogue }

    before { dialogue }

    specify { expect(friend.unread_messages_count).to eq(1) }

    context 'removed dialogue' do
      before { MessagesManager.new(user: friend, dialogue: dialogue).remove }

      specify { expect(friend.unread_messages_count).to eq(0) }
    end
  end

  describe '#cost=' do
    subject(:user) { User.new }

    context 'float cost' do
      specify { expect { user.cost = 300.5 }.to change { user.cost }.from(nil).to(300) }
      specify { expect { user.cost = 300.5 }.to change { user.subscription_cost }.from(nil).to(399) }
      specify { expect { user.cost = 300.5 }.to change { user.subscription_fees }.from(nil).to(99) }
    end

    context 'cost <= $3' do
      specify { expect { user.cost = 300 }.to change { user.cost }.from(nil).to(300) }
      specify { expect { user.cost = 300 }.to change { user.subscription_cost }.from(nil).to(399) }
      specify { expect { user.cost = 300 }.to change { user.subscription_fees }.from(nil).to(99) }
    end

    context 'cost >= $4 and <= $7' do
      specify { expect { user.cost = 400 }.to change { user.cost }.from(nil).to(400) }
      specify { expect { user.cost = 400 }.to change { user.subscription_cost }.from(nil).to(499) }
      specify { expect { user.cost = 400 }.to change { user.subscription_fees }.from(nil).to(99) }

      specify { expect { user.cost = 700 }.to change { user.cost }.from(nil).to(700) }
      specify { expect { user.cost = 700 }.to change { user.subscription_cost }.from(nil).to(899) }
      specify { expect { user.cost = 700 }.to change { user.subscription_fees }.from(nil).to(199) }
    end

    context 'cost >= $8 and <= $20' do
      specify { expect { user.cost = 800 }.to change { user.cost }.from(nil).to(800) }
      specify { expect { user.cost = 800 }.to change { user.subscription_cost }.from(nil).to(999) }
      specify { expect { user.cost = 800 }.to change { user.subscription_fees }.from(nil).to(199) }

      specify { expect { user.cost = 2000 }.to change { user.cost }.from(nil).to(2000) }
      specify { expect { user.cost = 2000 }.to change { user.subscription_cost }.from(nil).to(2300) }
      specify { expect { user.cost = 2000 }.to change { user.subscription_fees }.from(nil).to(300) }
    end

    context 'cost >= $21' do
      specify { expect { user.cost = 2100 }.to change { user.cost }.from(nil).to(2100) }
      specify { expect { user.cost = 2100 }.to change { user.subscription_cost }.from(nil).to(2415) }
      specify { expect { user.cost = 2100 }.to change { user.subscription_fees }.from(nil).to(315) }
    end
  end
end
