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
end