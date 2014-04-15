class StatusPost < Post

  # Returns nothing, nothing can be attached to status posts.
  # @param user [User]
  # @return [Array<Upload>]
  def self.pending_uploads_for(_)
    []
  end
end