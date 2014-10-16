module Concerns::Events::PostTracker
  # @param user [User]
  # @param post [Post]
  # @yield
  # @return [Event]
  def post_created(user: , post: , &block)
    Event.create! user: user, action: "#{post.type.tableize.singularize}_created", data: { id: post.id, type: post.type }, &block
  end

  # @param user [User]
  # @param post [Post]
  # @yield
  # @return [Event]
  def post_removed(user: , post: , &block)
    Event.create! user: user, action: "#{post.type.tableize.singularize}_removed", data: { id: post.id, type: post.type }, &block
  end

  # @param user [User]
  # @param post [Post]
  # @yield
  # @return [Event]
  def post_hidden(user: , post: , &block)
    Event.create! user: user, action: "#{post.type.tableize.singularize}_hidden", data: { id: post.id, type: post.type }, &block
  end

  # @param user [User]
  # @param post [Post]
  # @yield
  # @return [Event]
  def post_updated(user: , post: , &block)
    Event.create! user: user, action: "#{post.type.tableize.singularize}_updated", data: { id: post.id, type: post.type }, &block
  end

  # @param user [User]
  # @param post_type [String]
  # @yield
  # @return [Event]
  def post_canceled(user: , post_type: nil, &block)
    Event.create! user: user, action: 'post_canceled', data: { post_type: post_type }, &block
  end
end
