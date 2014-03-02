require 'spec_helper'

describe CurrentUserDecorator do
  let(:user) { User.new }
  subject { described_class.new(user) }
end