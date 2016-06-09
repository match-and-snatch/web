require 'spec_helper'

describe 'create_event matcher' do
  let(:user) { create :user }

  specify do
    expect { EventsManager.password_changed(user: user) }.to create_event(:password_changed)
  end

  specify do
    expect { EventsManager.password_changed(user: user) }.not_to create_event(:did_nothing_on_password)
  end

  specify do
    expect { EventsManager.password_changed(user: user) }.to create_event(:password_changed).with_user(user)
  end

  specify do
    expect { EventsManager.password_changed(user: user) }.not_to create_event(:password_changed).with_user(create(:user, email: 'another@user.ru'))
  end

  specify do
    expect { Event.create! data: {one: 1, 'two' => 2, three: '333'}, action: 'test' }.to create_event(:test).including_data(one: 1)
  end

  specify do
    expect { Event.create! data: {one: 1, 'two' => 2, three: '333'}, action: 'test' }.not_to create_event(:test).including_data(one: 2)
  end
end
