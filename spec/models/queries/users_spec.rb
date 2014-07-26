require 'spec_helper'

describe Queries::Users do
  before { create_user(email: 'spopov@gmail.com', full_name: 'Slava') }

  let!(:first_user) { create_user(email: 'szinin@gmail.com', full_name: 'Sergei') }
  let(:performer) { create_user(email: 'performer@gmail.com') }

  subject { described_class.new(user: performer, query: 'szinin@gmail.com') }

  specify { expect(subject.results).to eql [first_user] }
  specify { expect(subject.emails).to eql ['szinin@gmail.com'] }
end