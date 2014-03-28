require 'spec_helper'

describe User do
  describe '.create' do
    context 'profile owner' do
      it 'assigns slug' do
        expect(create_user(first_name: 'slava', last_name: 'popov', is_profile_owner: true).slug).to eq('slava-popov')
      end

      it 'generates uniq slug' do
        create_user(first_name: 'slava', last_name: 'popov', email: 'e@m.il', is_profile_owner: true)
        expect(create_user(first_name: 'slava', last_name: 'popov', email: 'e2@m.il', is_profile_owner: true).slug).to eq('slava-popov-1')
        expect(create_user(first_name: 'slava', last_name: 'popov', email: 'e3@m.il', is_profile_owner: true).slug).to eq('slava-popov-2')
      end
    end

    context 'subscriber' do
      it 'does not assign slug' do
        expect(create_user(first_name: 'slava', last_name: 'popov', is_profile_owner: false).slug).to eq(nil)
      end
    end
  end

  describe '#has_complete_profile?' do
    subject { described_class.new(is_profile_owner: true, slug: slug, subscription_cost: subscription_cost, holder_name: holder_name, routing_number: routing_number, account_number: account_number).has_complete_profile? }

    let(:slug) { 'sergei' }
    let(:subscription_cost) { 1 }
    let(:holder_name) { 'sergei' }
    let(:routing_number) { '123' }
    let(:account_number) { '12345' }

    it { should eq(true) }

    context 'empty slug' do
      let(:slug) {}
      it { should eq(false) }
    end

    context 'empty subscription_cost' do
      let(:subscription_cost) {}
      it { should eq(false) }
    end

    context 'empty holder_name' do
      let(:holder_name) {}
      it { should eq(false) }
    end

    context 'empty routing_number' do
      let(:routing_number) {}
      it { should eq(false) }
    end

    context 'empty account_number' do
      let(:account_number) {}
      it { should eq(false) }
    end
  end
end