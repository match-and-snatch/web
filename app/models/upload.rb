class Upload < ActiveRecord::Base
  serialize :transloadit_data, Hash
  belongs_to :uploadable, polymorphic: true

  # @param step_name [String, Symbol] See transloadit.yml
  # @return [String, nil]
  def url_on_step(step_name)
    if results = transloadit_data['results']
      if step = results[step_name].try(:first)
        return step['url']
      end
    end
  end
end
