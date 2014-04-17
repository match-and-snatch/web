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

  describe '#complete_profile?' do
    subject { described_class.new(is_profile_owner: true, profile_name: profile_name, slug: slug, cost: cost, holder_name: holder_name, routing_number: routing_number, account_number: account_number).complete_profile? }

    let(:profile_name) { 'Serezha' }
    let(:slug) { 'sergei' }
    let(:cost) { 1 }
    let(:holder_name) { 'sergei' }
    let(:routing_number) { '123' }
    let(:account_number) { '12345' }

    it { should eq(true) }

    context 'empty profile name' do
      let(:profile_name) { ' ' }
      it { should eq(false) }
    end

    context 'empty slug' do
      let(:slug) {}
      it { should eq(false) }
    end

    context 'empty cost' do
      let(:cost) {}
      it { should eq(false) }
    end

    context 'empty holder_name' do
      let(:holder_name) {}
      it { should eq(true) }
    end

    context 'empty routing_number' do
      let(:routing_number) {}
      it { should eq(true) }
    end

    context 'empty account_number' do
      let(:account_number) {}
      it { should eq(true) }
    end
  end

  describe '#admin?' do
    context 'admins' do
      subject { User.new is_admin: true }
      its(:admin?) { should eq(true) }

      context 'from config' do
        subject { User.new email: 'szinin@gmail.com' }
        its(:admin?) { should eq(true) }
      end
    end

    context 'non admins' do
      its(:is_admin?) { should eq(false) }
      its(:admin?) { should eq(false) }
    end
  end

  describe '.search_by_full_name' do
    let!(:matching_by_full_name) { create_user first_name: 'sergei', last_name: 'zinin' }
    let!(:matching_by_profile_name) do
      create_user(first_name: 'another', last_name: 'one', email: 'another@email.com').tap do |user|
        UserProfileManager.new(user).update_profile_name('serge')
      end
    end
    let!(:not_mathing) { create_user first_name: 'slava', last_name: 'popov', email: 'slava@gmail.com' }

    specify do
      expect(described_class.search_by_full_name('sergei')).to eq [matching_by_full_name, matching_by_profile_name]
    end
  end
end