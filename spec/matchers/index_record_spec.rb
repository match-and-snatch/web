require 'spec_helper'

describe '#index_record' do
  let!(:record) { create :user }
  let!(:another_record) { create :user }

  it { expect { record.elastic_index_document }.to index_record(record) }
  it { expect { record.elastic_index_document }.not_to index_record(another_record) }
  it { expect { record.elastic_index_document }.to index_record(record).using_index('users').using_type('default') }
  it { expect { record.elastic_index_document }.not_to index_record(record).using_index('users').using_type('wrong_type') }
end
