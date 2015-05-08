require 'spec_helper'

describe Api::DialoguesController, type: :controller do
  let(:user) { create_user api_token: 'token' }
  let(:friend) { create_user email: 'sender@gmail.com', api_token: 'friend_token' }
  let(:dialogue) { MessagesManager.new(user: user).create(target_user: friend, message: 'test').dialogue }

  describe 'GET #index' do
    subject(:perform_request) { get 'index' }

    context 'authorized' do
      before { sign_in_with_token user.api_token }

      it { should be_success }

      specify do
        perform_request
        expect(assigns('dialogues')).to be_empty
      end

      context 'with open dialogues' do
        let!(:recent_message) { MessagesManager.new(user: user).create(target_user: friend, message: 'test') }

        before { MessagesManager.new(user: friend).create(target_user: user, message: 'test') }
        before { MessagesManager.new(user: friend).create(target_user: friend, message: 'test') }

        it 'renders dialogues only related to the user' do
          perform_request
          expect(assigns('dialogues')).to eql([recent_message.dialogue])
        end
      end
    end

    context 'unauthorized' do
      its(:status) { should eq(401) }
    end
  end

  describe 'GET #show' do
    subject(:perform_request) { get 'show', id: dialogue.id }

    context 'authorized' do
      before { sign_in_with_token user.api_token }

      context 'dialogue exists' do
        its(:status) { should eq(200) }
        it { should be_success }

        context 'sender reads recently sent message' do
          it 'marks dialogue as read' do
            expect { perform_request }.not_to change { dialogue.reload.unread? }
          end
        end

        context 'receiver reads recently received message' do
          before { sign_in_with_token friend.api_token }

          it 'marks dialogue as read' do
            expect { perform_request }.to change { dialogue.reload.unread? }.from(true).to(false)
          end
        end
      end

      context 'dialogue does not exist' do
        let(:dialogue) { double('dialogue', id: 5) }
        its(:status) { should eq(404) }
      end

      context 'foreign dialogue' do
        let(:dialogue) { MessagesManager.new(user: friend).create(target_user: friend, message: 'test').dialogue }
        its(:status) { should eq(401) }
      end
    end
  end

  describe 'DELETE #destroy' do
    subject { delete 'destroy', id: dialogue.id }

    context 'unauthorized access' do
      its(:status) { should eq(401) }
    end

    context 'authorized access' do
      context 'as dialogue creator' do
        before { sign_in_with_token user.api_token }

        its(:status) { should eq(200) }
      end

      context 'as a dialogue target' do
        before { sign_in_with_token friend.api_token }

        its(:status) { should eq(200) }
      end

      context 'as anybody else' do
        let(:anybody) { create_user email: 'anybody@else.com', api_token: 'anybody' }

        before { sign_in_with_token anybody.api_token }

        its(:status) { should eq(401) }
      end
    end
  end
end
