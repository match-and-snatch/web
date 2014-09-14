require 'spec_helper'

describe CurrentUserDecorator do
  let(:user) { User.new }
  subject { described_class.new(user) }

  describe '#can?' do
    context 'admin' do
      let(:user) { User.new is_admin: true }

      describe 'dialogues' do
        let(:user) { create_user }
        let(:foreigner) { create_user email: 'foreigner@gmail.com' }
        let(:user_dialogue) { MessagesManager.new(user: user).create(target_user: user, message: 'test').dialogue }
        let(:foreign_dialogue) { MessagesManager.new(user: foreigner).create(target_user: foreigner, message: 'test').dialogue }

        it 'can see it is own dialogues' do
          expect(subject.can?(:see, user_dialogue)).to eql(true)
        end

        it 'cannot see foreign messages' do
          expect(subject.can?(:see, foreign_dialogue)).to eql(false)
        end
      end
    end
  end

  describe '#==' do
    let(:user) { create_user }

    specify do
      expect(subject).to eq(user)
    end

    specify do
      expect(subject).to eq(subject)
    end

    specify do
      expect(subject).not_to eq(User.new)
    end
  end

  describe '#latest_subscriptions' do
    let(:user) { create_user }

    context 'without subscriptions' do
      specify do
        expect(subject.latest_subscriptions).to eq([])
      end
    end

    context 'with subscriptions' do
      let!(:old_subscription) do
        Timecop.freeze 2.weeks.ago do
          SubscriptionManager.new(subscriber: user).subscribe_to(create_profile email: 'target3@user.com')
        end
      end

      let!(:old_removed_subscription) do
        Timecop.freeze 2.weeks.ago do
          manager = SubscriptionManager.new(subscriber: user)
          manager.subscribe_to(create_profile email: 'target2@user.com').tap do
            manager.unsubscribe
          end
        end
      end

      let!(:recent_subscription) { SubscriptionManager.new(subscriber: user).subscribe_to(create_profile email: 'target@user.com') }

      specify do
        expect(subject.latest_subscriptions.count).to eq(2)
        expect(subject.latest_subscriptions[0][0]).to eq(recent_subscription)
        expect(subject.latest_subscriptions[0][1]).to be_a(ProfileDecorator)
        expect(subject.latest_subscriptions[1][0]).to eq(old_subscription)
        expect(subject.latest_subscriptions[1][1]).to be_a(ProfileDecorator)
      end
    end
  end
end
