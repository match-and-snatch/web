class AddLowHighQPlaylistsToVideos < ActiveRecord::Migration
  def change
    add_column :uploads, :high_quality_playlist_url, :text
    add_column :uploads, :low_quality_playlist_url, :text
  end
end
