class AccountInfo::BaseController < ApplicationController
  before_filter :authenticate!
end