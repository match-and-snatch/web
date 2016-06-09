require 'spec_helper'

describe ApiResponsePresenter do
  let(:user) { create(:user, :profile_owner) }

  subject { described_class.new(CurrentUserDecorator.new(user)) }

  describe '#current_user_data' do
    it { expect { subject.current_user_data }.not_to raise_error }
  end

  describe '#billing_information_data' do
    let(:subscriptions) { SubscriptionsPresenter.new(user: user) }
    let(:contributions) { user.contributions.recurring.limit(200) }

    it { expect { subject.billing_information_data(subscriptions: subscriptions, contributions: contributions) }.not_to raise_error }
  end

  describe '#subscription_data' do
    let(:subscriber) { create(:user, email: 'subscriber@gmail.com') }
    let(:subscription) { SubscriptionManager.new(subscriber: subscriber).subscribe_to(user) }

    it { expect { subject.subscription_data(subscription) }.not_to raise_error }
  end

  describe '#subscriptions_data' do
    it { expect { subject.subscriptions_data }.not_to raise_error }
  end

  describe '#post_data' do
    let(:post) { PostManager.new(user: user).create_status_post(message: 'test') }

    it { expect { subject.post_data(post) }.not_to raise_error }
  end

  describe '#comment_data' do
    let(:post) { PostManager.new(user: user).create_status_post(message: 'test') }
    let(:comment) { CommentManager.new(user: user, post: post).create(message: 'test') }

    it { expect { subject.comment_data(comment) }.not_to raise_error }
  end

  context 'dialogues and messages' do
    let(:target_user) { create(:user, email: 'another_user@mail.com') }
    let(:message) { MessagesManager.new(user: user).create(message: 'test', target_user: target_user) }
    let(:dialogue) { message.dialogue }

    describe '#dialogues_data' do
      it { expect { subject.dialogues_data([dialogue]) }.not_to raise_error }
    end

    describe '#dialogue_data' do
      it { expect { subject.dialogue_data(dialogue) }.not_to raise_error }
    end

    describe '#messages_data' do
      it { expect { subject.messages_data([message]) }.not_to raise_error }
    end

    describe '#message_data' do
      it { expect { subject.message_data(message) }.not_to raise_error }
    end
  end

  describe '#mentions_data' do
    it { expect { subject.mentions_data([user]) }.not_to raise_error }
  end

  describe '#basic_profile_data' do
    it { expect { subject.basic_profile_data(user) }.not_to raise_error }
  end

  describe '#profile_details_data' do
    it { expect { subject.profile_details_data }.not_to raise_error }
  end

  describe '#account_data' do
    it { expect { subject.account_data(user) }.not_to raise_error }
  end

  describe '#profile_settings_data' do
    it { expect { subject.profile_settings_data(user) }.not_to raise_error }
  end

  describe '#user_data' do
    it { expect { subject.user_data(user) }.not_to raise_error }
  end

  describe '#profiles_list_data' do
    it { expect { subject.profiles_list_data }.not_to raise_error }
  end

  describe '#contribution_data' do
    it { expect { subject.contribution_data }.not_to raise_error }
  end

  describe '#profile_type_data' do
    let(:profile_type) { ProfileTypeManager.new.create(title: 'some title') }

    it { expect { subject.profile_type_data(profile_type) }.not_to raise_error }
  end

  describe '#pending_video_data' do
    let(:video) { UploadManager.new(user).create_video(ActionController::ManagebleParameters.new(transloadit_video_data_params)) }

    it { expect { subject.pending_video_data(video) }.not_to raise_error }
  end

  describe '#audios_data' do
    it { expect { subject.audios_data }.not_to raise_error }
  end

  describe '#welcome_media_data' do
    let(:video) { UploadManager.new(user).create_video(ActionController::ManagebleParameters.new(transloadit_video_data_params)) }

    it { expect { subject.welcome_media_data(video) }.not_to raise_error }
  end
end
