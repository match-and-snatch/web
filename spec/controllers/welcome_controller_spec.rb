require 'spec_helper'

describe WelcomeController do
  describe 'GET #show' do
    subject { get 'show' }
    it { should be_success }
  end
end