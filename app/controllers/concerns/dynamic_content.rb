module Concerns::DynamicContent
  extend ActiveSupport::Concern

  included do
    cattr_accessor :_dynamic_template do
      File.join('layouts', self.name.demodulize.singularize.underscore.gsub('_controller', ''))
    end
  end

  module ClassMethods
    def dynamic_template(value)
      self._dynamic_template = value
    end
  end

  protected

  # @param status [String]
  # @param json [Hash]
  # @option json [String, nil] :template
  def json_render_html(status, json = {})
    respond_to do |wants|
      wants.html do
        @content = json_body(json)
        render template: _dynamic_template
      end

      wants.json do
        json[:html] ||= json_body(json)
        json_response status, json
      end
    end
  end
end
