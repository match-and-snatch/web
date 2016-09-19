class Dashboard::Admin::UploadsController < Dashboard::Admin::BaseController

  def index
    @users = User.joins(:source_uploads).
               where("uploads.removed = 'f'").
               select('users.*, SUM(uploads.filesize) as uploaded_bytes').
               group('users.id').
               having('SUM(uploads.filesize) > 0').
               order('SUM(uploads.filesize) DESC').page(params[:page]).per(20)

    @total_uploaded = Upload.not_removed.sum(:filesize)

    json_render
  end
end
