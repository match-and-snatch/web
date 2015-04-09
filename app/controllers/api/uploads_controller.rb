class Api::UploadsController < Api::BaseController
  include Transloadit::Rails::ParamsDecoder

  before_action :load_upload!, only: [:destroy]

  protect(:destroy) { can? :manage, @upload }
  protect(:create) { current_user.authorized? }

  def create
    raise NotImplementedError
  end

  def destroy
    @upload.delete
    EventsManager.upload_removed(user: current_user.object, upload: @upload)
    json_success
  end

  protected

  def load_upload!
    @upload = Upload.where(id: params[:id]).first or error(404)
  end

  def manager
    @manager ||= UploadManager.new(current_user.object)
  end
end
