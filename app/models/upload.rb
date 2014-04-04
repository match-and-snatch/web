class Upload < ActiveRecord::Base
  self.inheritance_column = nil
  serialize :transloadit_data, Hash
  belongs_to :uploadable, polymorphic: true

  scope :pending, -> { where uploadable_id: nil }
  scope :posts, -> { where uploadable_type: 'Post' }

  # @param step_name [String, Symbol] See transloadit.yml
  # @return [String, nil]
  def url_on_step(step_name)
    attr_on_step(step_name, 'url')
  end

  def attr_on_step(step_name, attribute)
    if results = transloadit_data['results']
      if step = results[step_name].try(:first)
        return step[attribute.to_s]
      end
    end
  end

  def video?
    'video' == type
  end

  def image?
    'image' == type
  end

end
