require 'spec_helper'

describe Queries::Comments do
  let(:post) { create(:status_post) }

  subject { described_class.new(post: post) }

  describe '#results' do
    context 'without comments' do
      it { expect(subject.results).to eq([]) }
    end

    context 'with comments' do
      let!(:comment) { create(:comment, post: post) }
      let!(:second_comment) { create(:comment, post: post) }

      it { expect(subject.results).to eq([comment, second_comment]) }

      context 'multiple comments' do
        let!(:third_comment) { create(:comment, post: post) }
        let!(:forth_comment) { create(:comment, post: post) }
        let!(:fifth_comment) { create(:comment, post: post) }
        let!(:sixth_comment) { create(:comment, post: post) }

        it { expect(subject.results).to eq([second_comment, third_comment, forth_comment, fifth_comment, sixth_comment]) }

        it 'paginates results' do
          expect(described_class.new(post: post, start_id: second_comment.id).results).to eq([comment])
        end

        context 'with hidden comments' do
          let!(:forth_comment) { create(:comment, post: post, hidden: true) }
          let!(:sixth_comment) { create(:comment, post: post, hidden: true) }

          context 'as post owner' do
            it { expect(subject.results).to eq([second_comment, third_comment, forth_comment, fifth_comment, sixth_comment]) }
          end

          context 'as subscriber' do
            subject { described_class.new(post: post, performer: create(:user)) }

            it { expect(subject.results).to eq([comment, second_comment, third_comment, fifth_comment]) }
          end

          context 'as comment author' do
            subject { described_class.new(post: post, performer: forth_comment.user) }

            it { expect(subject.results).to eq([comment, second_comment, third_comment, forth_comment, fifth_comment]) }
          end
        end
      end
    end
  end

  describe '#has_more_comments?' do
    let!(:comment) { create(:comment, post: post) }
    let!(:second_comment) { create(:comment, post: post) }

    it { expect(subject.has_more_comments?).to eq(false) }

    context 'multiple comments' do
      let!(:third_comment) { create(:comment, post: post) }
      let!(:forth_comment) { create(:comment, post: post) }
      let!(:fifth_comment) { create(:comment, post: post) }
      let!(:sixth_comment) { create(:comment, post: post) }

      it { expect(subject.has_more_comments?).to eq(true) }
    end
  end

  describe '#last_comment_id' do
    context 'without comments' do
      it { expect(subject.last_comment_id).to be_nil }
    end

    context 'with comments' do
      let!(:comment) { create(:comment, post: post) }
      let!(:second_comment) { create(:comment, post: post) }

      it { expect(subject.last_comment_id).to eq(comment.id) }
    end
  end
end
