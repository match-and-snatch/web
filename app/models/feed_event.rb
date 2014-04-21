class FeedEvent < ActiveRecord::Base
  serialize :data, Hash

  belongs_to :target, polymorphic: true # post
  belongs_to :target_user, class_name: 'User'
  belongs_to :subscription_target_user, class_name: 'User'
end
