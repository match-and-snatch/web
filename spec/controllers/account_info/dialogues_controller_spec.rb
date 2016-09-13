describe AccountInfo::DialoguesController, type: :controller do
  let(:user) { create(:user) }
  let(:friend) { create :user, email: 'sender@gmail.com' }
  let(:dialogue) { MessagesManager.new(user: user).create(target_user: friend, message: 'test').dialogue }
  let!(:subscription) { create :subscription, user: user, target_user: friend }

  describe 'GET #index' do
    subject(:perform_request) { get 'index' }

    context 'authorized' do
      before { sign_in user }
      it { is_expected.to be_success }

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
      its(:status) { is_expected.to eq(401) }
    end
  end

  describe 'GET #show' do
    subject(:perform_request) { get :show, params: {id: dialogue.id} }

    context 'authorized' do
      before { sign_in user }

      context 'dialogue exists' do
        its(:status) { is_expected.to eq(200) }
        it { is_expected.to be_success }

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
        its(:status) { is_expected.to eq(404) }
      end

      context 'foreign dialogue' do
        let(:dialogue) { MessagesManager.new(user: friend).create(target_user: friend, message: 'test').dialogue }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end

  describe 'GET #confirm_removal' do
    subject { get :confirm_removal, params: {id: dialogue.id} }

    context 'not authorized' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized' do
      before { sign_in }
      it { is_expected.to be_success }
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: {id: dialogue.id} }

    context 'unauthorized access' do
      its(:status) { is_expected.to eq(401) }
    end

    context 'authorized access' do
      context 'as dialogue creator' do
        before { sign_in user }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as a dialogue target' do
        before { sign_in friend }
        its(:status) { is_expected.to eq(200) }
      end

      context 'as anybody else' do
        before { sign_in }
        its(:status) { is_expected.to eq(401) }
      end
    end
  end
end
