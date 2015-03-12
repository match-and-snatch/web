class UploadsController < ApplicationController
  include Transloadit::Rails::ParamsDecoder

  before_action :authenticate!, except: [:show, :playlist]
  before_action :load_upload, only: [:show, :destroy, :playlist]

  protect(:destroy) { can? :manage, @upload }

  def show
    @upload.user.itunes_enabled? or error(404)
    @post = @upload.uploadable or error(404)
  end

  def create
    raise NotImplementedError
  end

  def destroy
    @upload.delete
    EventsManager.upload_removed(user: current_user.object, upload: @upload)
  end

  protected

  def load_upload
    @upload = Upload.where(id: params[:id]).first or error(404)
  end

  def manager
    @manager ||= UploadManager.new(current_user.object)
  end
end

