class FillFilesizeColumn < ActiveRecord::Migration
  def up
    Upload.where(type: 'image').delete_all
    Upload.where(type: 'video').delete_all
    Upload.find_each do |upload|
      upload.filesize = upload.transloadit_data['uploads'][0]['size']
      upload.save
      puts upload.filesize.inspect
    end
  end

  def down
  end
end
