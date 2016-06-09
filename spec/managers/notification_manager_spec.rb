require 'spec_helper'

describe NotificationManager do
  let(:profile_owner) { create(:user, :profile_owner, email: 'profile_owner@gmail.com') }
  let(:subscriber) { create(:user, email: 'subscriber@gmail.com') }
  let(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_to(profile_owner) }
  let(:status_post) { create(:status_post, message: 'some text', user: profile_owner) }

  describe '.notify_recurring_payment_failed' do
    subject(:notify) { described_class.notify_recurring_payment_failed(failure) }
    let(:failure) { PaymentFailure.create(user: subscriber, target: subscription) }

    before do
      stub_const('PaymentsMailer', double('mailer', failed: double('mail', deliver_now: true)).as_null_object)
    end

    specify do
      expect(PaymentsMailer).to receive(:failed).with(failure)
      notify
    end

    context 'recently failed another payment' do
      let(:another_subscription) { create :subscription, user: subscriber }
      before { PaymentFailure.create(user: subscriber, target: another_subscription, created_at: 1.hour.ago) }

      specify do
        expect(PaymentsMailer).not_to receive(:failed)
        notify
      end
    end

    context 'failed long time ago' do
      let(:another_subscription) { create :subscription, user: subscriber }
      before { PaymentFailure.create(user: subscriber, target: another_subscription, created_at: 5.hours.ago) }

      specify do
        expect(PaymentsMailer).to receive(:failed).with(failure)
        notify
      end
    end
  end

  describe '.notify_post_created' do
    subject(:notify) { described_class.notify_post_created(status_post) }

    before do
      stub_const('PostsMailer', double('mailer', created: double('mail', deliver_now: true)).as_null_object)
    end

    specify do
      expect(PostsMailer).not_to receive(:created).with(status_post, subscriber)
      notify
    end

    context 'with subscribers' do
      before { subscription }

      specify do
        expect(PostsMailer).to receive(:created).with(status_post, subscriber)
        notify
      end

      context 'removed subscription' do
        before { SubscriptionManager.new(subscription: subscription).unsubscribe }

        specify do
          expect(PostsMailer).not_to receive(:created).with(status_post, subscriber)
          notify
        end
      end

      context 'notification disabled on subscription' do
        before { SubscriptionManager.new(subscription: subscription).disable_notifications }

        specify do
          expect(PostsMailer).not_to receive(:created).with(status_post, subscriber)
          notify
        end
      end
    end
  end

  describe '.notify_comment_created' do
    let(:comment) { CommentManager.new(user: subscriber, post: status_post).create(message: 'test', mentions: { profile_owner.id.to_s => profile_owner.full_name }) }

    subject(:notify) { described_class.notify_comment_created(comment) }

    before do
      stub_const('PostsMailer', double('mailer', mentioned: double('mail', deliver_now: true)).as_null_object)
      subscription
    end

    specify do
      expect(PostsMailer).to receive(:mentioned).with(comment, profile_owner)
      notify
    end
  end

  context 'vacation mode notifications' do
    before do
      stub_const('ProfilesMailer', double('mailer', vacation_enabled: double('mail', deliver_now: true)).as_null_object)
      stub_const('ProfilesMailer', double('mailer', vacation_disabled: double('mail', deliver_now: true)).as_null_object)
    end

    describe '.notify_vacation_enabled' do
      subject(:notify) { described_class.notify_vacation_enabled(profile_owner) }

      specify do
        expect(ProfilesMailer).not_to receive(:vacation_enabled)
        notify
      end

      context 'with subscribers' do
        specify do
          expect(ProfilesMailer).to receive(:vacation_enabled).with(subscription)
          notify
        end

        context 'removed subscription' do
          before { SubscriptionManager.new(subscription: subscription).unsubscribe }

          specify do
            expect(ProfilesMailer).not_to receive(:vacation_enabled)
            notify
          end
        end
      end
    end

    describe '.notify_vacation_disabled' do
      subject(:notify) { described_class.notify_vacation_disabled(profile_owner) }

      specify do
        expect(ProfilesMailer).not_to receive(:vacation_disabled)
        notify
      end

      context 'with subscribers' do
        specify do
          expect(ProfilesMailer).to receive(:vacation_disabled).with(subscription)
          notify
        end

        context 'removed subscription' do
          before { SubscriptionManager.new(subscription: subscription).unsubscribe }

          specify do
            expect(ProfilesMailer).not_to receive(:vacation_disabled)
            notify
          end
        end
      end
    end
  end
end
