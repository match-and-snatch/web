require 'spec_helper'

describe Queries::Users do
  let!(:first_user) { create_user(email: 'szinin@gmail.com', full_name: 'Sergei') }
  let!(:second_user) { create_user(email: 'spopov@gmail.com', full_name: 'Slava') }
  let!(:performer) { create_user(email: 'performer@gmail.com') }
  let!(:third_user) { create_user(email: 'third@gmail.com') }

  subject { described_class.new(user: performer, query: 'szinin@gmail.com, spopov@gmail.com, performer@gmail.com') }

  its(:results) { should =~ [first_user, second_user] }
  its(:emails) { should =~ ['szinin@gmail.com', 'spopov@gmail.com'] }
end