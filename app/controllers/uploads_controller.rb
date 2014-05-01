class UploadsController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  before_filter :authenticate!, except: [:show]
  before_filter :load_upload, only: [:show, :destroy]

  protect(:destroy) { can? :manage, @upload }

  def show
    @post = @upload.uploadable or error(404)
  end

  def create
    raise NotImplementedError
  end

  def destroy
    @upload.delete
  end

  protected

  def load_upload
    @upload = Upload.where(id: params[:id]).first or error(404)
  end

  def manager
    @manager ||= UploadManager.new(current_user.object)
  end
end