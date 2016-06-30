module Concerns::NameValidator
  # @param name [String, nil]
  # @param field_name [Symbol]
  def validate_account_name(name, field_name: :full_name)
    return fail_with field_name => :empty if name.blank?
    return fail_with field_name => :contains_numbers if name[/\d/]
    return unless validate_name_length(name)
    # TODO: return fail_with field_name => :invalid_name unless name.match(/\A[\w\s\-]+\z/i)
    true
  end

  # @param name [String, nil]
  # @param field_name [Symbol]
  def validate_name_length(name, field_name: :full_name, limit: 200)
    if name
      fail_with field_name => :too_long if name.length > limit
    end

    true
  end
end
