require 'spec_helper'

describe '#index_record' do
  let!(:user) { create :user }
  let!(:another_record) { create :user }

  it { expect { user.elastic_index_document }.to index_record(user) }
  it { expect { user.elastic_index_document }.not_to index_record(another_record) }
  it { expect { user.elastic_index_document }.to index_record(user).using_index('users').using_type('default') }
  it { expect { user.elastic_index_document }.not_to index_record(user).using_index('users').using_type('wrong_type') }
end
