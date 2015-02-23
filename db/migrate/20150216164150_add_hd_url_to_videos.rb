class AddHdUrlToVideos < ActiveRecord::Migration
  def change
    add_column :uploads, :hd_url, :text
  end
end
