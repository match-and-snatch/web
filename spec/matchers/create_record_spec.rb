require 'spec_helper'

describe 'create_record' do
  it { expect { create_user }.to create_record(User) }
  it { expect { create_user }.to create_record(User).once }
  it { expect { create_user }.to create_record(User).exactly(1.times) }
  it { expect { create_user }.to create_record(User).exactly(1) }
  it { expect { create_user }.to create_record(User).exactly('1 time in this spec') }
  it { expect {}.not_to create_record(User) }
  it { expect { create_user }.not_to create_record(User).exactly(2.times) }
  it { expect { create_user }.not_to create_record(User).exactly('2 times now') }
  it { expect { Post.create! }.not_to create_record(User) }

  it do
    expect do
      create_user
      create_user email: 'another@email.com'
    end.to create_record(User)
  end

  it do
    expect do
      create_user
      create_user email: 'another@email.com'
    end.not_to create_record(User).exactly(1.times)
  end

  it do
    expect do
      create_user
      create_user email: 'another@email.com'
    end.not_to create_record(User).exactly(1)
  end

  it do
    expect do
      create_user
      create_user email: 'another@email.com'
    end.not_to create_record(User).exactly('1 time in this spec')
  end

  it do
    expect do
      create_user
      create_user email: 'another@email.com'
    end.to create_record(User).exactly(2.times)
  end

  it do
    expect do
      create_user
      create_user email: 'another@email.com'
    end.to create_record(User).exactly('2 times in this spec')
  end

  it do
    expect do
      create_user
      create_user email: 'another@email.com'
    end.to create_record(User).exactly(2)
  end

  it do
    expect do
      create_user
      create_user email: 'another@email.com'
    end.not_to create_record(User).once
  end

  it { expect { create_user email: 'test@connectpal.com' }.to create_record(User).matching(email: 'test@connectpal.com').once }
  it { expect { create_user email: 'test@connectpal.com' }.not_to create_record(User).matching(email: 'wrong@connectpal.com').once }
  it { expect { create_user email: 'test@connectpal.com' }.to create_record(User.where(email: 'test@connectpal.com')) }
  it { expect { create_user email: 'test@connectpal.com' }.not_to create_record(User.where(email: 'wrong@connectpal.com')) }

  it do
    expect do
      expect do
        create_user
        create_user email: 'another@email.com'
      end.to create_record(User).exactly(1)
    end.to raise_error(/^Expected to create a single User record/)
  end

  context 'initial count > 0' do
    before { create_user }
    it { expect { create_user email: 'another@email.com' }.to create_record(User).once }
  end

  context 'invalid calls' do
    it 'does not allow calling `once` and `exactly` in one chain' do
      expect { expect {}.not_to create_record(User).once.exactly(4) }.to raise_error(ArgumentError, /together/)
    end

    it 'does not allow calling `exactly` and `once` in one chain' do
      expect { expect {}.not_to create_record(User).exactly(4).once }.to raise_error(ArgumentError, /together/)
    end
  end
end