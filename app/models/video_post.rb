class VideoPost < Post

  # @param user [User]
  # @return [Array<Upload>]
  def self.pending_uploads_for(user)
    user.pending_post_uploads.videos
  end
end