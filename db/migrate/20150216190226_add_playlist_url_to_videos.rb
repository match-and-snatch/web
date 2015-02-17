class AddPlaylistUrlToVideos < ActiveRecord::Migration
  def change
    add_column :uploads, :playlist_url, :text
  end
end
