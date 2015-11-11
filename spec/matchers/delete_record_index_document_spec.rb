require 'spec_helper'

describe '#delete_record_index_document' do
  let(:record) { create :user }

  context 'indexed record' do
    before do
      update_index record
    end

    it do
      expect { record.elastic_delete_document }.to delete_record_index_document(record)
    end

    it do
      expect { record.elastic_delete_document }.to delete_record_index_document(record).from_index('users')
    end

    it do
      expect { record.elastic_delete_document }.to delete_record_index_document(record).from_index('users').from_type('default')
    end

    it do
      expect { record.elastic_delete_document }.not_to delete_record_index_document(record).from_index('users').from_type('wrong_type')
    end
  end

  context 'not indexed record' do
    it do
      expect { record.elastic_delete_document }.not_to delete_record_index_document(record)
    end
  end
end
