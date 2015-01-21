class Admin::UploadsController < Admin::BaseController

  def index
    @users = User.joins(:source_uploads).
      where("uploads.removed = 'f'").
      select('users.*, SUM(uploads.filesize) as uploaded_bytes').
      group('users.id').
      having('SUM(uploads.filesize) > 0').
      order('SUM(uploads.filesize) DESC').limit(100)

    @total_uploaded = Upload.sum(:filesize)

    json_render
  end
end
