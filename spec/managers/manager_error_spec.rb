require 'spec_helper'

describe ManagerError do
  subject { described_class.new({email: 'is invalid', password: 'is not set'}) }

  its(:messages) { should == {email: 'is invalid', password: 'is not set'} }
  its(:message) { should == 'email and is invalid and password and is not set' }

  context 'only message given' do
    subject { described_class.new({message: 'you failed'}) }
    its(:message) { should == 'you failed' }
  end

  context 'only one message' do
    subject { described_class.new({login: 'is invalid'}) }
    its(:message) { should == 'login is invalid' }
  end
end