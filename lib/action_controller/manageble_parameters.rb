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

    # @param key [Symbol, String]
    # @return [Boolean, nil]
    def bool(key)
      if [true, 1, '1', 't'].include?(self[key])
        true
      elsif [false, 0, '0', 'f'].include?(self[key])
        false
      else
        nil
      end
    end
  end
end
