class SessionsController < ApplicationController
  popup :new do
    layout[:title] = 'Login'
  end
end