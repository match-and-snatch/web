module ActionController
  class ManagebleParameters < ::ActionController::Parameters

    # Returns params filtered for a manager interface input
    # @example
    #   Manager.new.perform_action(params.slice(:name, :title, :group))
    # @return [Hash]
    def slice(*keys)
      super(*keys.flatten).permit!.to_h.symbolize_keys
    end

    # @return [String]
    def to_yaml
      to_h.to_yaml
    end

    # @param key [Symbol, String]
    # @return [Boolean, nil]
    def bool(key)
      if [true, 'true', 1, '1', 't'].include?(self[key])
        true
      elsif [false, 'false', 0, '0', 'f'].include?(self[key])
        false
      else
        nil
      end
    end

    # @param key [Symbol, String]
    # @return [Boolean]
    def first_page?(key = :page)
      self[key].blank? || self[key] == '1'
    end
  end
end
