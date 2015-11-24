require 'spec_helper'

describe Post do
  describe 'Elasticpal::Indexable' do
    subject { Elasticpal::Query.new(model: Post).search(match: {message: 'Test'}) }

    describe 'elastic_index_document' do
      context 'with a not matching post in db' do
        let!(:not_matching) { create(:status_post) }
        let!(:post) { create(:status_post, message: 'Test') }

        before { update_index(not_matching, post) }

        it 'finds the matching record' do
          expect(subject.records).to eq([post])
        end
      end
    end

    describe '#elastic_delete_document' do
      let!(:post) { create(:status_post, message: 'Test') }

      before do
        update_index do
          post.elastic_delete_document
          refresh_index
        end
      end

      it { expect(subject.records).to eq([]) }
    end

    describe '.elastic_bulk_index' do
      let!(:first_post) { create(:status_post, message: 'Test') }
      let!(:second_post) { create(:status_post, message: 'Test') }
      before { update_index }

      it { expect(subject.records).to match_array([second_post, first_post]) }
    end
  end
end
