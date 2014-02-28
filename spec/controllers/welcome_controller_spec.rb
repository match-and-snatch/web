require 'spec_helper'

describe WelcomeController do
  describe 'GET #show' do
    subject { get 'show' }
    specify do
      expect(subject).to be_success
    end
  end
end