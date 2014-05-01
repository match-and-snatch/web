class FeedEvent < ActiveRecord::Base
  serialize :data, Hash

  belongs_to :target, polymorphic: true # post
  belongs_to :target_user, class_name: 'User'
  belongs_to :subscription_target_user, class_name: 'User'

  def self.label
    @label ||= self.name.tableize.gsub('_feed_event', '')
  end

  def self.message
    @message ||= I18n.t(label, scope: :feed)
  end

  def kind
    self.class.name.underscore
  end

  def message
    self.class.message
  end

  def label
    self.class.label
  end
end
