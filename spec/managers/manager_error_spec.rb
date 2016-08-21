require 'spec_helper'

RSpec.describe ManagerError do
  subject { described_class.new({email: 'is invalid', password: 'is not set'}) }

  its(:messages) { is_expected.to eq({email: 'is invalid', password: 'is not set'}) }
  its(:message) { is_expected.to eq('email and is invalid and password and is not set') }

  context 'only message given' do
    subject { described_class.new({message: 'you failed'}) }
    its(:message) { is_expected.to eq 'you failed' }
  end

  context 'only one message' do
    subject { described_class.new({login: 'is invalid'}) }
    its(:message) { is_expected.to eq 'login is invalid' }
  end
end
