require 'spec_helper'

describe ManagerError do
  subject { described_class.new({email: 'is invalid', password: 'is not set'}) }

  its(:messages) { should == {email: 'is invalid', password: 'is not set'} }
  its(:message) { should == 'email and is invalid and password and is not set' }
end