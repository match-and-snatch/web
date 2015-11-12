require 'spec_helper'

describe '#delete_record_index_document' do
  let(:user) { create :user }

  context 'indexed user' do
    before do
      update_index user
    end

    it do
      expect { user.elastic_delete_document }.to delete_record_index_document(user)
    end

    it do
      expect { user.elastic_delete_document }.to delete_record_index_document(user).from_index('users')
    end

    it do
      expect { user.elastic_delete_document }.to delete_record_index_document(user).from_index('users').from_type('default')
    end

    it do
      expect { user.elastic_delete_document }.not_to delete_record_index_document(user).from_index('users').from_type('wrong_type')
    end
  end

  context 'not indexed user' do
    it do
      expect { user.elastic_delete_document }.not_to delete_record_index_document(user)
    end
  end
end
