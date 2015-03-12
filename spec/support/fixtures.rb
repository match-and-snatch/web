module Fixtures
  extend self

  # @example
  #   Fixtures.transloadit.audio
  def transloadit
    ::Fixtures::Transloadit
  end

  module Transloadit
    extend self

    Dir[Rails.root.join("spec/support/fixtures/transloadit/**/*")].each do |f|
      fixture_name = f.gsub(/^.+\//, '').gsub(/\..+$/, '').to_sym
      instance_name = :"@#{fixture_name}"

      define_method fixture_name do
        instance_variable_get(instance_name) || instance_variable_set(instance_name, JSON.parse(File.read(f)))
      end
    end
  end
end
