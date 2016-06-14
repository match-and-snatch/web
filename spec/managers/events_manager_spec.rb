require 'spec_helper'

describe EventsManager do
  subject(:manager) { described_class }

  before { StripeMock.start }
  after { StripeMock.stop }

  let(:user) { create(:user, :profile_owner) }
  let!(:photo) { create(:photo, user: user) }
  let!(:_post) { PostManager.new(user: user).create_status_post(message: 'some post') }

  let(:another_user) { create(:user, :profile_owner, email: 'another_user@mail.com') }

  context 'sessions events' do
    describe '.user_logged_in' do
      it { expect { manager.user_logged_in(user: user) }.to create_event(:logged_in) }
    end

    describe '.user_registered' do
      let!(:user) { create(:user, :profile_owner) }
      it { expect { manager.user_registered(user: user.reload) }.to create_event(:registered) }
    end

    describe '.restore_password_requested' do
      it { expect { manager.restore_password_requested(user: user) }.to create_event(:restore_password_requested) }
    end

    describe '.password_restored' do
      it { expect { manager.password_restored(user: user) }.to create_event(:password_restored) }
    end
  end

  describe '.account_photo_changed' do
    it { expect { manager.account_photo_changed(user: user, photo: photo) }.to create_event(:account_photo_changed) }
  end

  describe '.account_information_changed' do
    it { expect { manager.account_information_changed(user: user, data: {}) }.to create_event(:account_information_changed) }
  end

  describe '.password_changed' do
    it { expect { manager.password_changed(user: user) }.to create_event(:password_changed) }
  end

  describe '.payout_information_changed' do
    it { expect { manager.payout_information_changed(user: user) }.to create_event(:payout_information_changed) }
  end

  describe '.slug_changed' do
    it { expect { manager.slug_changed(user: user, slug: 'slug') }.to create_event(:slug_changed) }
  end

  describe '.credit_card_updated' do
    it { expect { manager.credit_card_updated(user: user) }.to create_event(:credit_card_updated) }
  end

  describe '.vacation_mode_enabled' do
    it { expect { manager.vacation_mode_enabled(user: user, reason: 'poexal v tailand') }.to create_event(:vacation_mode_enabled) }
  end

  describe '.vacation_mode_disabled' do
    it { expect { manager.vacation_mode_disabled(user: user) }.to create_event(:vacation_mode_disabled) }
  end

  context 'comments events' do
    let!(:comment) { CommentManager.new(user: user, post: _post).create(message: 'test') }

    before do
      SubscriptionManager.new(subscriber: user).subscribe_to(another_user)
    end

    describe '.comment_created' do
      it { expect { manager.comment_created(user: user, comment: comment) }.to create_event(:comment_created) }
    end

    describe '.comment_updated' do
      it { expect { manager.comment_updated(user: user, comment: comment) }.to create_event(:comment_updated) }
    end

    describe '.comment_shown' do
      before do
        manager.comment_hidden(user: user, comment: comment)
      end

      it { expect { manager.comment_shown(user: user, comment: comment) }.to change { Event.where(action: 'comment_hidden').count }.from(1).to(0) }
      it { expect { manager.comment_shown(user: user, comment: comment) }.not_to change { 1 } }
    end

    describe '.comment_hidden' do
      it { expect { manager.comment_hidden(user: user, comment: comment) }.to create_event(:comment_hidden) }
    end

    describe '.comment_removed' do
      it { expect { manager.comment_removed(user: user, comment: comment) }.to create_event(:comment_removed) }
    end
  end

  context 'payment events' do
    describe '.payment_created' do
      it { expect { manager.payment_created(user: user, payment: Payment.new) }.to create_event(:payment_created) }
    end

    describe '.payment_failed' do
      it { expect { manager.payment_failed(user: user, payment_failure: PaymentFailure.new) }.to create_event(:payment_failed) }
    end
  end

  context 'post events' do
    describe '.post_created' do
      it { expect { manager.post_created(user: user, post: _post) }.to create_event(:status_post_created) }
    end

    describe '.post_removed' do
      it { expect { manager.post_removed(user: user, post: _post) }.to create_event(:status_post_removed) }
    end

    describe '.post_hidden' do
      it { expect { manager.post_hidden(user: user, post: _post) }.to create_event(:status_post_hidden) }
    end

    describe '.post_updated' do
      it { expect { manager.post_updated(user: user, post: _post) }.to create_event(:status_post_updated) }
    end

    describe '.post_canceled' do
      it { expect { manager.post_canceled(user: user, post_type: nil) }.to create_event(:post_canceled) }
    end
  end

  context 'profile events' do
    describe '.profile_created' do
      it { expect { manager.profile_created(user: user, data: {}) }.to create_event(:profile_created) }
    end

    describe '.profile_page_removed' do
      it { expect { manager.profile_page_removed(user: user) }.to create_event(:profile_page_removed) }
    end

    describe '.profile_picture_changed' do
      it { expect { manager.profile_picture_changed(user: user, picture: photo) }.to create_event(:profile_picture_changed) }
    end

    describe '.cover_picture_changed' do
      it { expect { manager.cover_picture_changed(user: user, picture: photo) }.to create_event(:cover_picture_changed) }
    end

    describe '.profile_name_changed' do
      it { expect { manager.profile_name_changed(user: user, name: 'dimon') }.to create_event(:profile_name_changed) }
    end

    describe '.subscription_cost_changed' do
      it { expect { manager.subscription_cost_changed(user: user, from: 5, to: 10) }.to create_event(:subscription_cost_changed) }
    end

    describe '.benefits_list_updated' do
      it { expect { manager.benefits_list_updated(user: user, benefits: []) }.to create_event(:benefits_list_updated) }
    end

    describe '.welcome_media_added' do
      it { expect { manager.welcome_media_added(user: user, media: photo) }.to create_event(:welcome_media_added) }
    end

    describe '.contact_info_changed' do
      it { expect { manager.contact_info_changed(user: user, info: {}) }.to create_event(:contact_info_changed) }
    end

    describe '.welcome_media_removed' do
      it { expect { manager.welcome_media_removed(user: user) }.to create_event(:welcome_media_removed) }
    end
  end

  context 'subscriptions evesnts' do
    let!(:subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(another_user) }

    describe '.subscription_created' do
      it { expect { manager.subscription_created(user: user, subscription: subscription, restored: false) }.to create_event(:subscription_created) }
    end

    describe '.subscription_canceled' do
      it { expect { manager.subscription_cancelled(user: user, subscription: subscription) }.to create_event(:subscription_canceled) }
    end

    describe '.subscription_notifications_enabled' do
      before do
        manager.subscription_notifications_disabled(user: user, subscription: subscription)
      end

      specify do
        expect { manager.subscription_notifications_enabled(user: user, subscription: subscription) }.to change { Event.where(action: 'subscription_notifications_disabled').count }.from(1).to(0)
      end
    end

    describe '.subscription_notifications_disabled' do
      it { expect { manager.subscription_notifications_disabled(user: user, subscription: subscription) }.to create_event(:subscription_notifications_disabled) }
    end
  end

  describe '.profile_type_added' do
    it { expect { manager.profile_type_added(user: user, profile_type: ProfileType.new) }.to create_event(:profile_type_added) }
  end

  describe '.profile_type_removed' do
    it { expect { manager.profile_type_removed(user: user, profile_type: ProfileType.new) }.to create_event(:profile_type_removed) }
  end

  describe '.file_uploaded' do
    it { expect { manager.file_uploaded(user: user, file: photo) }.to create_event(:photo_uploaded) }
  end

  describe '.upload_removed' do
    it { expect { manager.upload_removed(user: user, upload: photo) }.to create_event(:photo_removed) }
  end

  describe '.like_created' do
    it { expect { manager.like_created(user: user, like: Like.new) }.to create_event(:like_created) }
  end

  describe '.like_removed' do
    before do
      LikesManager.new(user).toggle(_post)
    end

    it { expect { manager.like_removed(user: user, like: Like.first) }.to change { Event.where(action: 'like_created').count }.from(1).to(0) }
  end

  describe '.message_created' do
    it { expect { manager.message_created(user: user, message: Message.new) }.to create_event(:message_created) }
  end

  describe '.dialogue_marked_as_read' do
    it { expect { manager.dialogue_marked_as_read(user: user, dialogue: Dialogue.new) }.to create_event(:dialogue_marked_as_read) }
  end

  describe '.transfer_sent' do
    it { expect { manager.transfer_sent(user: user, transfer: StripeTransfer.new) }.to create_event(:transfer_sent) }
  end
end
