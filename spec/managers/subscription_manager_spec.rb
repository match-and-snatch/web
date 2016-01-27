require 'spec_helper'

describe SubscriptionManager do
  let(:subscriber)   { create_user(email: 'szinin@gmail.com') }
  let(:another_user) { create_profile(email: 'another@user.com') }

  subject(:manager) { described_class.new(subscriber: subscriber) }

  describe '#register_subscribe_and_pay_via_token' do
    before { StripeMock.start }
    after { StripeMock.stop }

    let(:register_data) do
      {
          stripe_token: token,
          card: {},
          email: 'tester@tester.com',
          full_name: 'Tester Ivanovitch',
          password: 'gfhjkmqe',
          expiry_month: '05',
          expiry_year: '18',
          zip: '123456',
          city: 'LA',
          state: 'CA',
          address_line_1: 'Test',
          address_line_2: nil,
          target: another_user
      }
    end

    context 'stripe token is not set (eg failed validation on frontend)' do
      let(:token) { }

      subject(:subscribe) do
        manager.register_subscribe_and_pay_via_token(register_data)
      end

      specify do
        expect { subscribe }.to raise_error(MissingCcTokenError)
      end

      specify do
        expect { subscribe rescue nil }.not_to change { Payment.count }
      end

      specify do
        expect { subscribe rescue nil }.not_to change { Subscription.count }
      end
    end

    context 'stripe token is invalid' do
      let(:token) { 'invalid' }

      subject(:subscribe) do
        manager.register_subscribe_and_pay_via_token(register_data)
      end

      xit do
        expect { subscribe }.to raise_error
      end

      xit do
        expect { subscribe rescue nil }.not_to change { Payment.count }
      end

      xit do
        expect { subscribe rescue nil }.not_to change { Subscription.count }
      end
    end

    context 'stripe token is set (received one from Stripe via stripe.js)' do
      let(:cc_data) do
        { number: '4242424242424242',
          cvc: '000',
          expiry_month: '05',
          expiry_year: '18',
          zip: '123456',
          city: 'LA',
          state: 'CA',
          address_line_1: 'Test',
          address_line_2: nil }
      end

      let(:token) { StripeMock.generate_card_token(cc_data) }

      subject(:subscribe) do
        manager.register_subscribe_and_pay_via_token(register_data)
      end

      specify do
        expect { subscribe rescue nil }.to change { Payment.count }
      end

      specify do
        expect { subscribe rescue nil }.to change { Subscription.count }
      end
    end
  end

  describe '#register_subscribe_and_pay' do
    before { StripeMock.start }
    after { StripeMock.stop }

    let(:register_data) do
      {
          email: 'tester@tester.com',
          full_name: 'Tester Ivanovitch',
          password: 'gfhjkmqe',
          cvc: '000',
          expiry_month: '05',
          expiry_year: '18',
          zip: '123456',
          city: 'LA',
          state: 'CA',
          address_line_1: 'Test',
          address_line_2: nil
      }
    end

    context 'CC fails' do
      subject(:subscribe) { manager.register_subscribe_and_pay(register_data.merge(number: '4000000000000341', target: another_user)) rescue PaymentError }

      before { StripeMock.prepare_card_error(:card_declined) }

      it 'registers user' do
        expect { subscribe }.to create_record(User).once.matching(email: register_data[:email])
      end
      it 'marks user as billing failed' do
        subscribe
        expect(User.where(email: register_data[:email]).last.try(:billing_failed)).to eq(true)
      end
      it 'does not create feed event' do
        expect { subscribe }.not_to create_record(SubscribedFeedEvent)
      end
      it 'does not create subscription_created event' do
        expect { subscribe }.not_to create_event(:subscription_created)
      end
      it 'creates rejected subscription' do
        expect { subscribe }.to create_record(Subscription).once.matching(rejected: true)
      end
      it 'does not create payment' do
        expect { subscribe }.not_to create_record(Payment)
      end
      it 'crerates payment failure' do
        expect { subscribe }.to create_record(PaymentFailure).once
      end
      it 'does not sent email about subscription' do
        expect { subscribe }.not_to deliver_email(to: register_data[:email], subject: /You're now subscribed to/)
      end
      it 'sent email about registration' do
        expect { subscribe }.not_to deliver_email(to: register_data[:email], subject: /Welcome to ConnectPal!/)
      end
    end

    context 'payment success' do
      subject(:subscribe) { manager.register_subscribe_and_pay(register_data.merge(number: '4242424242424242', target: another_user)) }

      it { should be_a Subscription }
      it { should be_valid }
      it { should_not be_new_record }

      it 'registers user' do
        expect { subscribe }.to create_record(User).once.matching(email: register_data[:email], last_four_cc_numbers: '4242')
      end

      it 'creates subscription' do
        expect { subscribe }.to create_record(Subscription).once
      end
      it 'creates payment' do
        expect { subscribe }.to create_record(Payment).once
      end

      it 'creates feed event' do
        expect { subscribe }.to create_record(SubscribedFeedEvent).once
      end
      it 'creates subscription_created event' do
        expect { subscribe }.to create_event(:subscription_created)
      end

      it 'about register' do
        expect { subscribe }.not_to deliver_email(to: register_data[:email], subject: /Welcome to ConnectPal!/)
      end
      it 'sends email about subscription' do
        expect { subscribe }.to deliver_email(to: register_data[:email], subject: /You're now subscribed to/)
      end

      context 'forbidden email' do
        subject(:subscribe) { manager.register_subscribe_and_pay(register_data.merge(email: "tester@#{APP_CONFIG['forbidden_email_domains'].sample}", number: '4242424242424242', target: another_user)) }

        it 'returns error' do
          expect { subscribe }.to raise_error(ManagerError) { |e| expect(e.messages[:errors]).to include(email: t_error(:invalid)) }
        end

        it 'does not register user' do
          expect { subscribe rescue nil }.to create_record(User)
        end
      end
    end
  end

  describe '#unsubscribe' do
    before { manager.subscribe_to(another_user) }

    it { expect { manager.unsubscribe }.to change { another_user.subscribers_count }.by(-1) }

    context 'fake' do
      before { manager.subscribe_to(another_user, fake: true) }

      it { expect { manager.unsubscribe }.to change { another_user.subscribers_count }.by(-1) }
      it { expect { manager.unsubscribe }.not_to create_record(UnsubscribedFeedEvent) }
      it { expect { manager.unsubscribe }.to create_event(:subscription_canceled).with_subject(another_user) }
    end

    context 'unsubscribe one more time' do
      before { manager.unsubscribe }

      it { expect { manager.unsubscribe }.to raise_error(ManagerError,  /Already unsubscribed/) }
      it { expect { manager.unsubscribe rescue nil }.not_to create_record(UnsubscribedFeedEvent) }
      it { expect { manager.unsubscribe rescue nil }.not_to create_event(:subscription_canceled).with_subject(another_user) }
    end

    context 'logger disabled' do
      it { expect { manager.unsubscribe(log_subscriptions_count: false) }.not_to change { another_user.subscribers_count } }
    end
  end

  describe '#unsubscribe_entirely' do
    before do
      manager.subscribe_to(another_user)
      manager.subscribe_to(create_profile(email: 'second_another@user.com'))
    end

    it do
      expect { manager.unsubscribe_entirely }.to change { subscriber.subscriptions.not_removed.count }.from(2).to(0)
    end
  end

  describe '#subscribe_to' do
    context 'another user' do
      subject { manager.subscribe_to(another_user) }

      it { should be_a Subscription }
      it { should be_valid }
      it { should_not be_new_record }

      specify do
        expect { manager.subscribe_to(another_user) }.to create_record(Subscription)
          .once.matching(target_user_id: another_user.id, user_id: subscriber.id)
      end

      specify do
        expect { manager.subscribe_to(another_user) }.to index_record(subscriber).using_index('users').using_type('mentions')
      end

      context 'locked profile owner' do
        let(:another_user) { create :user, :profile_owner, locked: true }

        specify do
          expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError, /disabled/)
        end
      end

      context 'fake' do
        subject(:subscribe) { manager.subscribe_to(another_user, fake: true) }

        it { should be_a Subscription }
        it { should be_valid }
        it { should_not be_new_record }
        it { should be_fake }

        specify do
          expect { subscribe }.to create_record(Subscription)
        end

        it do
          expect { subscribe }.not_to create_record(FeedEvent)
        end

        it 'does not increase recent_subsrciptions_count' do
          expect { subscribe }.not_to change { subscriber.recent_subscriptions_count }
        end

        context 'with fake user' do
          let(:subscriber) { User.fake }

          it { should be_a Subscription }
          it { should be_valid }
          it { should_not be_new_record }
          it { should be_fake }
          its(:user) { should eq(subscriber) }
          it { expect { subscribe }.to create_record(Subscription).matching(target_user: another_user, user: subscriber) }
        end

        context 'subscribing more than 4 times' do
          it 'does not ban the subscriber' do
            5.times do
              manager.subscribe_to(another_user, fake: true)
            end

            expect(subscriber.reload.locked?).to eq(false)
          end
        end
      end

      it 'does not create subscription_created event' do
        expect { manager.subscribe_to(another_user) }.not_to create_event(:subscription_created)
      end

      it 'activates subscriber if he is not yet active' do
        expect { manager.subscribe_to(another_user) }.to change { subscriber.reload.activated? }.to(true)
      end

      it 'sets current cost from user' do
        expect(subject.cost).to eq(another_user.cost)
      end

      it 'increases recent_subsrciptions_count' do
        expect { manager.subscribe_to(another_user) }.to change { subscriber.recent_subscriptions_count }.by(1)
      end

      it 'sets time of recent subscription', freeze: true do
        expect { manager.subscribe_to(another_user) }.to change { subscriber.recent_subscription_at }.to(Time.zone.now)
      end

      context 'already subscribed' do
        let!(:subscription) do
          manager.subscribe_to(another_user)
        end

        it 'does not allow to subscribe twice' do
          expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError)
        end

        it 'does not create subscription_created event twice' do
          expect { manager.subscribe_to(another_user) rescue nil }.not_to create_event(:subscription_created)
        end

        context 'unsubscribed subscription' do
          before { StripeMock.start }
          after { StripeMock.stop }

          let!(:subscription) do
            Timecop.freeze 32.days.ago do
              manager.subscribe_to(another_user)
            end
          end

          before do
            described_class.new(subscriber: subscriber, subscription: subscription).unsubscribe
          end

          specify do
            expect { manager.subscribe_to(another_user) }.not_to raise_error
          end

          it 'subscribes user back' do
            expect { manager.subscribe_to(another_user) }.to change { subscriber.subscribed_to?(another_user) }.from(false).to(true)
          end

          it 'does not create duplicate subscription' do
            expect { manager.subscribe_to(another_user) rescue nil }.not_to change { Subscription.count }
          end
        end

        context 'failed subscription' do
          before do
            described_class.new(subscriber: subscriber, subscription: subscription).reject
          end

          it 'does not allow to subscribe twice' do
            expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError)
          end

          it 'does not create duplicate subscription' do
            expect { manager.subscribe_to(another_user) rescue nil }.not_to change { Subscription.count }
          end

          it 'does not create subscription_created event' do
            expect { manager.subscribe_to(another_user) rescue nil }.not_to create_event(:subscription_created)
          end
        end
      end

      context 'subscribing more than 4 times' do
        let(:profiles) do
          4.times.map do
            create :user, :profile_owner
          end
        end

        before do
          profiles.each do |profile|
            manager.subscribe_to(profile)
          end
        end

        it 'locks an account' do
          expect { manager.subscribe_to(another_user) }.to change { subscriber.locked? }.from(false).to(true)
        end

        it 'sets billing lock type' do
          expect { manager.subscribe_to(another_user) }.to create_event('account_locked').with_user(subscriber).including_data(type: 'billing', reason: 'subscription_limit')
        end

        context 'mature profiles' do
          let(:profiles) do
            4.times.map do
              create :user, :profile_owner, has_mature_content: true
            end
          end
          let(:new_profiles) do
            2.times.map do
              create :user, :profile_owner, has_mature_content: true
            end
          end

          before do
            Timecop.freeze(2.days.from_now) do
              new_profiles.each do |profile|
                manager.subscribe_to(profile)
              end
            end
          end

          it "doesn't allow user to subscribe on any other profile", freeze: 2.days.from_now do
            expect { manager.subscribe_to(create(:user, :profile_owner)) rescue nil }.not_to change { subscriber.subscriptions.count }
          end

          specify freeze: 2.days.from_now do
            expect { manager.subscribe_to(create(:user, :profile_owner)) }.to raise_error(SubscriptionLimitReachedError)
          end

          context 'adult subscriptions limit is increased' do
            before { subscriber.update_attribute(:adult_subscriptions_limit, 7) }

            specify freeze: 2.days.from_now do
              expect { manager.subscribe_to(create(:user, :profile_owner)) }.to create_record(Subscription)
            end
          end
        end

        context '48 hours passed' do
          it 'allows subscribing' do
            Timecop.travel(48.hours.since) do
              expect { manager.subscribe_to(another_user) }.not_to change { subscriber.locked? }.from(false)
            end
          end
        end

        context 'account was unlocked' do
          before do
            manager.subscribe_to(create_profile(email: 'another_5@user.com'))
            UserManager.new(subscriber.reload).unlock
          end

          it 'allows subscribing' do
            expect { manager.subscribe_to(another_user) }.not_to change { subscriber.locked? }.from(false)
          end
        end

        context 'more than 5 subscriptions in 48 hours' do
          before do
            manager.subscribe_to(create_profile(email: 'another_5@user.com'))
          end

          it 'locks an account' do
            expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError, /locked/)
          end

          it 'does not subscribe' do
            expect { manager.subscribe_to(another_user) rescue nil }.not_to create_record(Subscription)
          end

          context '48 hours passed' do
            it 'does not allow subscribing' do
              Timecop.travel(48.hours.since) do
                expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError, /locked/)
              end
            end
          end
        end
      end
    end

    context 'target with not approved cost' do
      let(:another_user) { create_profile(email: 'another_one@user.com', cost: 35) }

      it 'does not allow to subscribe' do
        expect { manager.subscribe_to(another_user) }.to raise_error(ManagerError, /Can't subscribe to user with not approved cost/)
      end
    end

    context 'any unsubscribable thing' do
      specify do
        expect { manager.subscribe_to(Subscription) }.to raise_error(ArgumentError, /Cannot subscribe/)
      end

      it 'does not create subscription_created event' do
        expect { manager.subscribe_to(Subscription) rescue nil }.not_to create_event(:subscription_created)
      end
    end
  end

  describe '#restore' do
    before { StripeMock.start }
    after { StripeMock.stop }

    let!(:subscription) do
      manager.subscribe_to(another_user)
    end

    context 'removed subscription' do
      before do
        manager.unsubscribe
      end

      specify do
        expect { manager.restore }.to change { subscription.removed? }.from(true).to(false)
      end

      context 'changed costs' do
        before do
          UserProfileManager.new(another_user).change_cost!(cost: 300, update_existing_subscriptions: false)
        end

        it 'updates cost to new value' do
          expect { manager.restore }.to change { subscription.reload.cost }.from(500).to(300)
        end
      end
    end

    context 'rejected subscription' do
      let(:subscriber) do
        create_user(email: 'szinin@gmail.com').tap do |u|
          UserProfileManager.new(u).update_cc_data(number: '4242424242424242', cvc: '123', expiry_month: 12, expiry_year: 19,
            address_line_1: 'test', address_line_2: 'test', state: 'test', city: 'test', zip: '12345')
        end
      end

      before do
        manager.reject
      end

      it 'tries to retry payment' do
        expect { manager.restore }.to change { subscription.rejected? }.from(true).to(false)
      end

      context 'paid subscription' do
        let!(:subscription) do
          manager.subscribe_and_pay_for(another_user)
        end

        it 'restores subscription' do
          expect { manager.restore }.to change { subscription.rejected? }.from(true).to(false)
        end

        it do
          expect { manager.restore }.to change { subscription.rejected_at }.to(nil)
        end

        it do
          expect { manager.restore }.not_to create_record(Payment)
        end

        it do
          expect { manager.restore }.not_to create_record(PaymentFailure)
        end
      end

      context 'subscription never charged' do
        it 'creates feed event' do
          expect { manager.restore }.to create_record(SubscribedFeedEvent).once
        end
        it 'creates subscription_created event' do
          expect { manager.restore }.to create_event(:subscription_created)
        end
        it 'sends email about new subscription' do
          expect { manager.restore }.to deliver_email(to: subscriber.email, subject: /You're now subscribed to/)
        end
        it 'creates payment' do
          expect { manager.restore }.to create_record(Payment).once
        end
        it 'makes subscription active' do
          expect { manager.restore }.to change { subscription.rejected? }.from(true).to(false)
        end
      end
    end
  end

  describe '#mark_as_processing', freeze: true do
    let(:subscription) { manager.subscribe_to(another_user) }

    it { expect { manager.mark_as_processing }.to change { subscription.processing_payment }.from(false).to(true) }
    it { expect { manager.mark_as_processing }.to change { subscription.processing_started_at }.from(nil).to(Time.zone.now) }
  end

  describe '#unmark_as_processing' do
    let(:subscription) { manager.subscribe_to(another_user) }

    before do
      subscription
      manager.mark_as_processing
    end

    it { expect { manager.unmark_as_processing }.to change { subscription.processing_payment }.from(true).to(false) }
    it { expect { manager.unmark_as_processing }.to change { subscription.processing_started_at }.to(nil) }
  end
end
