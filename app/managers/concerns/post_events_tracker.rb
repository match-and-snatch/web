module Concerns::PostEventsTracker
  # @param user [User]
  # @param post [Post]
  def post_created(user: , post: )
    Event.create! user: user, action: "#{post.type.tableize}_created", data: { id: post.id, type: post.type }
  end

  # @param user [User]
  # @param post [Post]
  def post_removed(user: , post: )
    Event.create! user: user, action: "#{post.type.tableize}_destroyed", data: { id: post.id, type: post.type }
  end

  # @param user [User]
  # @param post [Post]
  def post_updated(user: , post: )
    Event.create! user: user, action: "#{post.type.tableize}_updated", data: { id: post.id, type: post.type }
  end

  # @param user [User]
  def post_canceled(user: , post_type: nil)
    Event.create! user: user, action: 'post_cancelled', data: { post_type: post_type }
  end
end