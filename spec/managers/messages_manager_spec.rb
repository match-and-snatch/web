require 'spec_helper'

describe MessagesManager do
  let(:user) { create_user }
  let(:target_user) { create_user email: 'another_user@mail.com' }

  subject { described_class.new(user: user) }

  it 'creates new message' do
    expect(subject.create(message: 'test', target_user: target_user)).to be_a Message
  end
end
