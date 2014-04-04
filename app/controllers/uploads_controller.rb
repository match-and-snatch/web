class UploadsController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  before_filter :authenticate!

  def create
    raise NotImplementedError
  end

  protected

  def manager
    @manager ||= UploadManager.new(current_user.object)
  end
end