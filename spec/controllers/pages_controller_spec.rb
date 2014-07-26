require 'spec_helper'

describe PagesController, type: :controller do
  describe 'GET #about' do
    subject { get 'about' }
    it { should be_success }
  end

  describe 'GET #pricing' do
    subject { get 'pricing' }
    it { should be_success }
  end

  describe 'GET #contact_us' do
    subject { get 'contact_us' }
    it { should be_success }
  end

  describe 'GET #terms_of_use' do
    subject { get 'terms_of_use' }
    it { should be_success }
  end

  describe 'GET #privacy_policy' do
    subject { get 'privacy_policy' }
    it { should be_success }
  end
end