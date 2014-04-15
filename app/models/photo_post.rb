class PhotoPost < Post

  # @param user [User]
  # @return [Array<Upload>]
  def self.pending_uploads_for(user)
    user.pending_post_uploads.photos
  end
end