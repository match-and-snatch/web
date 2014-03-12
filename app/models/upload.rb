class Upload < ActiveRecord::Base
  serialize :transloadit_data, Hash
  belongs_to :uploadable, polymorphic: true
end
