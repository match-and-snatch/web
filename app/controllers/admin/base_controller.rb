class Admin::BaseController < ApplicationController
  protect { current_user.admin? }
end