require 'spec_helper'

describe AccountInfo::DialoguesController, type: :controller do
  let(:user) { create_user }
  let(:friend) { create_user email: 'sender@gmail.com' }

  describe 'GET #index' do
    subject(:perform_request) { get 'index' }

    context 'authorized' do
      before { sign_in user }
      it { should be_success }

      specify do
        perform_request
        expect(assigns('dialogues')).to be_empty
      end

      context 'with open dialogues' do
        before { MessagesManager.new(user: friend).create(target_user: user, message: 'test') }
        let!(:recent_message) { MessagesManager.new(user: user).create(target_user: friend, message: 'test') }
        before { MessagesManager.new(user: friend).create(target_user: friend, message: 'test') }

        it 'renders dialogues only related to the user' do
          perform_request
          expect(assigns('dialogues')).to eql([recent_message.dialogue])
        end
      end
    end

    context 'unauthorized' do
      its(:status) { should == 401 }
    end
  end

  describe 'GET #show' do
    subject(:perform_request) { get 'show', id: dialogue.id }

    context 'authorized' do
      before { sign_in user }

      context 'dialogue exists' do
        let(:dialogue) { MessagesManager.new(user: user).create(target_user: friend, message: 'test').dialogue }
        it { should be_success }

        context 'sender reads recently sent message' do
          it 'marks dialogue as read' do
            expect { perform_request }.not_to change { dialogue.reload.unread? }
          end
        end

        context 'receiver reads recently received message' do
          before { sign_in friend }

          it 'marks dialogue as read' do
            expect { perform_request }.to change { dialogue.reload.unread? }.from(true).to(false)
          end
        end
      end

      context 'dialogue does not exist' do
        let(:dialogue) { double('dialogue', id: 5) }
        its(:status) { should == 404 }
      end

      context 'foreign dialogue' do
        let(:dialogue) { MessagesManager.new(user: friend).create(target_user: friend, message: 'test').dialogue }
        its(:status) { should == 401 }
      end
    end
  end
end
