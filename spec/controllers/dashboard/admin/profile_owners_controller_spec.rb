require 'spec_helper'

describe Dashboard::Admin::ProfileOwnersController, type: :controller do
  before { sign_in create_admin(email: 'admin@gmail.com') }
  let(:user) { create_user }
end
