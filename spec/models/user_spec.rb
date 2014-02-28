require 'spec_helper'

describe User do
  describe '.create' do
    it 'assigns slug' do
      expect(create_user(first_name: 'slava', last_name: 'popov').slug).to eq('slava-popov')
    end

    it 'generates uniq slug' do
      create_user(first_name: 'slava', last_name: 'popov', email: 'e@m.il')
      expect(create_user(first_name: 'slava', last_name: 'popov', email: 'e2@m.il').slug).to eq('slava-popov-1')
      expect(create_user(first_name: 'slava', last_name: 'popov', email: 'e3@m.il').slug).to eq('slava-popov-2')
    end
  end
end