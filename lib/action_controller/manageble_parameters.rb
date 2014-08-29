module ActionController
  class ManagebleParameters < ::ActionController::Parameters

    # Returns params filtered for a manager interface input
    # @example
    #   Manager.new.perform_action(params.slice(:name, :title, :group))
    # @return [Hash]
    def slice(*keys)
      super(*(keys.flatten)).symbolize_keys
    end

    # @return [String]
    def to_yaml
      to_hash.to_yaml
    end
  end
end
