require 'spec_helper'

describe User do
  describe 'Elasticpal::Indexable' do
    subject { Elasticpal::Query.new(model: User).search(match: {profile_name: 'Test'}) }

    describe 'elastic_index_document' do
      context 'with a not matching user in db' do
        let!(:not_matching) { create :user }
        let!(:user) { create :user, :profile_owner, profile_name: 'Test' }

        before { update_index(not_matching, user) }

        it 'finds the matching record' do
          expect(subject.records).to eq([user])
        end
      end
    end

    describe '#elastic_delete_document' do
      let!(:user) { create :user, :profile_owner, profile_name: 'Test' }

      before do
        update_index do
          user.elastic_delete_document
          refresh_index
        end
      end

      it { expect(subject.records).to eq([]) }
    end

    describe '.elastic_bulk_index' do
      let!(:first_user) { create(:user, :profile_owner, profile_name: 'Test') }
      let!(:second_user) { create(:user, :profile_owner, profile_name: 'Test') }
      before { update_index }

      it { expect(subject.records).to match_array([second_user, first_user]) }
    end

    describe '.elastic_rebuild_index!' do
      let!(:user) { create(:user, :profile_owner, profile_name: 'Test') }

      before { update_index(user) }

      it { expect(subject.records).to match_array([user]) }

      context 'specified wrong index name' do
        it { expect { described_class.elastic_rebuild_index!('chuck norris') }.to raise_error(ArgumentError) }
      end
    end
  end

  describe '.create' do
    context 'profile owner' do
      it 'assigns slug' do
        expect(described_class.create(profile_name: 'slava popov', full_name: 'popov slava', email: 's@popov.com', is_profile_owner: true).slug).to eq('slavapopov')
      end

      it 'generates uniq slug' do
        described_class.create(profile_name: 'slava popov', full_name: 'popov slava', email: 'e@m.il', is_profile_owner: true)
        expect(described_class.create(profile_name: 'slava popov', full_name: 'popov slava', email: 'e2@m.il', is_profile_owner: true).slug).to eq('slavapopov-1')
        expect(described_class.create(profile_name: 'slava popov', full_name: 'popov slava', email: 'e3@m.il', is_profile_owner: true).slug).to eq('slavapopov-2')
      end
    end

    context 'subscriber' do
      it 'does not assign slug' do
        expect(described_class.create(profile_name: 'slava popov', is_profile_owner: false).slug).to eq(nil)
      end
    end
  end

  describe '#lock!', freeze: true do
    let(:user) { create(:user) }

    it { expect { user.lock! }.to change { user.reload.last_time_locked_at }.to(Time.zone.now) }
    it { expect { user.lock! }.to change { user.reload.locked? }.to(true) }
    it { expect { user.lock! }.to change { user.reload.lock_type }.to('account') }
    it { expect { user.lock! }.to change { user.reload.lock_reason }.to('manually_set') }
    it { expect { user.lock!(type: 'billing') }.to change { user.reload.lock_type }.to('billing') }
    it { expect { user.lock!(reason: 'cc_update_limit') }.to change { user.reload.lock_reason }.to('cc_update_limit') }
  end

  describe '#unlock!', freeze: true do
    let(:user) { create(:user) }

    context 'locked' do
      before { user.lock! }

      it { expect { user.unlock! }.to change { user.reload.locked? }.to(false) }
      it { expect { user.unlock! }.not_to change { user.reload.last_time_locked_at } }
    end

    context 'not locked' do
      it { expect { user.unlock! }.to raise_error(ArgumentError) }
    end
  end

  describe '#comment_picture_url' do
    let(:user) { create(:user, small_account_picture_url: nil) }

    it { expect(user.comment_picture_url).to be_nil }
    it { expect(user.comment_picture_url(profile_image: true)).to be_nil }

    context 'with account image' do
      let(:user) { create(:user) }

      it { expect(user.comment_picture_url).to eq(user.small_account_picture_url) }
      it { expect(user.comment_picture_url(profile_image: true)).to eq(user.small_account_picture_url) }
    end

    context 'with profile image' do
      let(:user) { create(:user, :profile_owner) }

      it { expect(user.comment_picture_url(profile_image: true)).to eq(user.small_profile_picture_url) }
    end

    context 'without profile image' do
      let(:user) { create(:user, :profile_owner, small_profile_picture_url: nil) }

      it { expect(user.comment_picture_url(profile_image: true)).to eq(user.small_account_picture_url) }
    end
  end

  describe '#denormalize_last_post_created_at!', freeze: true do
    let!(:user) { create(:user) }

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
    subject(:user) { create(:user, api_token: nil) }

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
    subject(:user) { create(:user, api_token: nil) }

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
      create(:user, is_profile_owner: true).tap do |user|
        user.create_top_profile!
      end
    end

    let(:non_profile_owner) do
      create(:user, is_profile_owner: false).tap do |user|
        user.create_top_profile!
      end
    end

    let(:non_top_user) { create(:user, :profile_owner) }

    it { is_expected.to include(top_user) }
    it { is_expected.not_to include(non_top_user) }
    it { is_expected.not_to include(non_profile_owner) }

    describe 'ordering' do
      let!(:middle_user) do
        create(:user, is_profile_owner: true, email: 'middle@middle.com').tap do |user|
          user.create_top_profile! position: 1
        end
      end

      let!(:top_user) do
        create(:user, is_profile_owner: true, email: 'top@top.com').tap do |user|
          user.create_top_profile! position: 0
        end
      end

      let!(:bottom_user) do
        create(:user, is_profile_owner: true, email: 'bottom@bottom.com').tap do |user|
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

  describe '#staff?' do
    its(:staff?) { should eq(false) }

    context 'admin' do
      subject { User.new is_admin: true }
      its(:staff?) { should eq(true) }
    end

    context 'sales' do
      subject { User.new is_sales: true }
      its(:staff?) { should eq(true) }
    end
  end

  describe '#subscribed_to?' do
    subject { user.subscribed_to?(target_user) }

    let(:user) { create(:user) }
    let(:target_user) { create(:user, :profile_owner, email: 'target@user.com') }

    context 'with' do
      let!(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

      context 'active subscription' do
        it { should eq(true) }
      end

      context 'rejected subscription' do
        before { StripeMock.start }
        after { StripeMock.stop }

        context "by user's fault" do
          before do
            StripeMock.prepare_card_error(:card_declined)
            PaymentManager.new(user: user).pay_for(subscription)
          end

          it { should eq(false) }
        end

        context "rejected by Stripe's fault" do
          before do
            StripeMock.prepare_error(Stripe::APIError.new("Api is down"), :new_charge)
            PaymentManager.new(user: user).pay_for(subscription)
          end

          it { should eq(true) }
        end
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

  describe '#recently_subscribed?' do
    let(:user) { create(:user) }

    context 'without subscriptions' do
      it { expect(user.recently_subscribed?).to eq(false) }
    end

    context 'with subscriptions' do
      let(:target_user) { create(:user, :profile_owner, email: 'target@user.com') }

      before { SubscriptionManager.new(subscriber: user).subscribe_to(target_user) }

      it { expect(user.recently_subscribed?).to eq(true) }

      context '24 hours passed' do
        it do
          Timecop.freeze(1.day.from_now) do
            expect(user.recently_subscribed?).to eq(true)
          end
        end
      end

      context '48 hours passed' do
        it do
          Timecop.freeze(2.days.from_now) do
            expect(user.recently_subscribed?).to eq(false)
          end
        end
      end
    end
  end

  describe '#welcome_audio' do
    subject(:user) { create(:user) }

    its(:welcome_audio) { should be_nil }

    context 'with welcome audio' do
      let(:welcome_audio_data) { welcome_audio_data_params }
      let(:welcome_audio) { UploadManager.new(user).create_audio(welcome_audio_data).first }

      its(:welcome_audio) { should eq(welcome_audio) }
    end
  end

  describe '#welcome_video' do
    subject(:user) { create(:user) }

    its(:welcome_video) { should be_nil }

    context 'with welcome video' do
      let(:welcome_video_data) { welcome_video_data_params }
      let(:welcome_video) { UploadManager.new(user).create_video(welcome_video_data) }

      its(:welcome_video) { should eq(welcome_video) }
    end
  end

  describe '#unread_messages_count' do
    let(:user) { create(:user) }
    let(:friend) { create(:user, email: 'sender@gmail.com') }
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

  describe '#contributions_allowed?' do
    subject(:user) { create :user, :profile_owner }

    context 'default' do
      its(:contributions_allowed?) { is_expected.to eq(false) }
    end

    context 'contribution enabled' do
      before { UserProfileManager.new(user).enable_contributions }

      its(:contributions_allowed?) { is_expected.to eq(false) }

      context 'user has 5 or more subscribers' do
        subject(:user) { create :user, :profile_owner, subscribers_count: 5 }

        its(:contributions_allowed?) { is_expected.to eq(true) }

        context 'user deleted his profile page' do
          subject(:user) { create :user, :profile_owner, subscribers_count: 5, is_profile_owner: false }
          its(:contributions_allowed?) { is_expected.to eq(false) }
        end

        context 'user account is locked' do
          before { UserManager.new(subject).lock(type: lock_type) }

          context 'with account related issue' do
            let(:lock_type) { :account }
            its(:contributions_allowed?) { is_expected.to eq(false) }
          end

          context 'with tos violation type' do
            let(:lock_type) { :tos }
            its(:contributions_allowed?) { is_expected.to eq(false) }
          end

          context 'with billing type' do
            let(:lock_type) { :billing }
            its(:contributions_allowed?) { is_expected.to eq(true) }
          end
        end
      end
    end
  end

  describe '#profile_payable?' do
    context 'profile owner' do
      subject { build :user, :profile_owner, user_attributes }
      let(:user_attributes) { {} }

      its(:profile_payable?) { is_expected.to eq(true) }

      context 'locked account' do
        let(:user_attributes) { {locked: true, lock_type: lock_type} }

        context 'with billing locked' do
          let(:lock_type) { 'billing' }
          its(:profile_payable?) { is_expected.to eq(true) }
        end

        context 'with tos locked' do
          let(:lock_type) { 'tos' }
          its(:profile_payable?) { is_expected.to eq(false) }
        end

        context 'with account locked' do
          let(:lock_type) { 'account' }
          its(:profile_payable?) { is_expected.to eq(false) }
        end
      end
    end

    context 'not a profile owner' do
      subject { create :user }
      its(:profile_payable?) { is_expected.to eq(false) }
    end
  end

  describe '#cost_approved?' do
    subject(:user) { create :user }

    context 'user never had a request' do
      its(:cost_approved?) { is_expected.to eq(true) }
    end

    context 'user requested a high price' do
      subject(:user) { create :user, cost: 85_00 }
      let!(:request) { create :cost_change_request, :pending, old_cost: nil, new_cost: 85_00, user: user }
      its(:cost_approved?) { is_expected.to eq(false) }

      context 'request approved' do
        let!(:request) { create :cost_change_request, :approved, old_cost: nil, new_cost: 85_00, user: user, performed: true }
        its(:cost_approved?) { is_expected.to eq(true) }

        context 'one of the requests was rejected before' do
          let!(:request) { create :cost_change_request, :rejected, old_cost: nil, new_cost: 85_00, user: user, performed: true }
          let!(:request2) { create :cost_change_request, :approved, old_cost: nil, new_cost: 85_00, user: user, performed: true }

          its(:cost_approved?) { is_expected.to eq(true) }
        end
      end

      context 'request rejected' do
        let!(:request) { create :cost_change_request, :rejected, old_cost: nil, new_cost: 85_00, user: user, performed: true }
        its(:cost_approved?) { is_expected.to eq(false) }

        context 'user decreased cost to reasonably low level' do
          let(:user) { create :user, cost: 1_00 }
          its(:cost_approved?) { is_expected.to eq(true) }
        end

        context 'one of the requests was approved before' do
          let!(:request) { create :cost_change_request, :approved, old_cost: nil, new_cost: 81_00, user: user, performed: true }
          let!(:request2) { create :cost_change_request, :rejected, old_cost: 81_00, new_cost: 85_00, user: user, performed: true }

          its(:cost_approved?) { is_expected.to eq(true) }
        end
      end
    end
  end

  describe '#cost_change_requests' do
    subject(:user) { create :user }

    describe '#current' do
      subject(:current_cost_request) { user.cost_change_requests.current }

      context 'there is a request pending' do
        let!(:pending_request) { create :cost_change_request, :pending, user: user }

        it 'returns current cost change request' do
          expect(current_cost_request).to eq(pending_request)
        end
      end

      context 'no pending requests' do
        specify do
          expect(current_cost_request).to be_nil
        end
      end
    end
  end

  describe '#cost_change_request' do
    subject(:user) { create :user }

    subject(:cost_change_request) { user.cost_change_request }

    context 'there is a request pending' do
      let!(:pending_request) { create :cost_change_request, :pending, user: user }

      it 'returns current cost change request' do
        expect(cost_change_request).to eq(pending_request)
      end
    end

    context 'no pending requests' do
      specify do
        expect(cost_change_request).to be_nil
      end
    end
  end
end
