class UsersController < ApplicationController
  popup :new do
    layout[:title] = 'Registration'
  end

  def create
    pass_flow(UserFlow.new.create(params)) { json_reload }
  end
end