class UsersController < ApplicationController
  popup :new do
    layout[:title] = 'Registration'
  end

  def create
    pass_flow(flow.create(params)) do
      login flow.user
      json_reload
    end
  end

  private

  def flow
    @flow ||= UserFlow.new
  end
end