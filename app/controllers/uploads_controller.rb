class UploadsController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  before_filter :authenticate!
  before_filter :load_upload, only: :destroy
  protect(:destroy) { can? :manage, @upload }

  def create
    raise NotImplementedError
  end

  def destroy
    @upload.delete
    json_replace
  end

  protected

  def load_upload
    @upload = Upload.where(id: params[:id]).first or error(404)
  end

  def manager
    @manager ||= UploadManager.new(current_user.object)
  end
end