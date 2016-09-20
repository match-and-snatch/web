module UserLinksHelper
  # @param user [User]
  # @param possessive [Boolean]
  # @param shorten [Boolean]
  # @param hide_adult_words [Boolean]
  # @param force_profile_name [Boolean]
  # @return [String, nil]
  def link_to_user(user, possessive: false, shorten: false, show_mature_name: true, force_profile_name: false, **options)
    return unless user

    user = user.object if user.kind_of? BaseDecorator
    name = if force_profile_name
             user.profile_name.presence || user.name
           else
             user.name
           end

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

    name = name.gsub(' ', '&nbsp;').html_safe

    link_to_if user.has_profile_page?, name, profile_url(user), options do
      content_tag :span, name, options
    end
  end
end
