class AccountInfo::BaseController < ApplicationController
  before_action :authenticate!
end