class Event < ActiveRecord::Base
  serialize :data, Hash

  belongs_to :target, polymorphic: true
end
