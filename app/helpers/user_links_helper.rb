module UserLinksHelper
  # @param user [User]
  # @param possessive [Boolean]
  # @param shorten [Boolean]
  # @param hide_adult_words [Boolean]
  # @return [String, nil]
  def link_to_user(user, possessive: false, shorten: false, show_mature_name: true)
    return unless user

    user = user.object if user.kind_of? BaseDecorator
    name = user.name
    options = {}

    if possessive
      name = name.possessive
    end

    unless show_mature_name
      name = cut_adult_words(name)
    end

    if shorten && name.size > 13
      name = name.truncate(13)
      options[:title] = user.name
    else
      name = name.first(40)
    end

    link_to_if user.has_profile_page?, name.gsub(/ /, '&nbsp;').html_safe, profile_url(user), options
  end
end
