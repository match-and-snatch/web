module Concerns::Subscribable

  # @return [User]
  def subscription_source_user
    raise NotImplementedError
  end
end