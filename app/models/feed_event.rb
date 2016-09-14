class FeedEvent < ApplicationRecord
  serialize :data, Hash

  belongs_to :target, polymorphic: true # post
  belongs_to :target_user, class_name: 'User'
  belongs_to :subscription_target_user, class_name: 'User'

  def self.label
    @label ||= self.name.tableize.gsub('_feed_event', '')
  end

  def self.message(data = {})
    if data.empty?
      @message ||= I18n.t(label, scope: :feed)
    else
      I18n.t(label, data.merge(scope: :feed))
    end
  end

  def kind
    self.class.name.underscore
  end

  def message
    self.class.message(data)
  end

  def title
    if target.respond_to?(:title)
      target.title
    end
  end

  def label
    self.class.label
  end

  def hide!
    self.hidden = true
    self.save!
  end

  def show!
    self.hidden = false
    self.save!
  end
end
