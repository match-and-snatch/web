describe Users::CleanStuffJob do
  describe '#perform' do
    subject(:perform) { described_class.new.perform }

    let(:user) { create(:user) }
    let!(:comment) { create(:comment, user: user) }
    let!(:like) { create(:like_for_comment, user: user, comment: comment) }

    it { expect { perform }.to deliver_email(to: APP_CONFIG['emails']['reports'], subject: /Clean Stuff Job/) }
    it { expect { perform }.not_to raise_error }
    it { expect { perform }.not_to delete_record(Comment) }
    it { expect { perform }.not_to delete_record(Like) }

    context 'with deleted users' do
      let(:user_to_delete) { create(:user) }
      let!(:comment_to_delete) { create(:comment, user: user_to_delete) }
      let!(:like_to_delete) { create(:like_for_comment, user: user_to_delete, comment: comment_to_delete) }

      before { user_to_delete.delete }

      it { expect { perform }.not_to delete_record(Comment).matching(id: comment.id) }
      it { expect { perform }.not_to delete_record(Like).matching(id: like.id) }

      it { expect { perform }.to delete_record(Comment).matching(id: comment_to_delete.id) }
      it { expect { perform }.to delete_record(Like).matching(id: like_to_delete.id) }
    end
  end
end
