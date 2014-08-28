module ApplicationHelper

  if Rails.env.development?
    # @overload
    # @param source [String] relative path to asset
    # @param options [Hash]
    # @return [String, nil]
    def compute_asset_host(source, options = {})
      fname = source.split('/').last
      return if Rails.application.assets.find_asset(fname)

      super(source, options)
    end
  end

  def object_checker_tag(object, field_name)
    data = {}
    data[:checked_url]   = polymorphic_path(["enable_#{field_name}", object])
    data[:unchecked_url] = polymorphic_path(["disable_#{field_name}", object])

    html_options = {id: "#{field_name}_#{object.id}_#{object.class.name}_checker", data: data, class: 'Checker', type: 'checkbox'}
    html_options['checked'] = 'checked' if object["#{field_name}_enabled"]

    tag :input, html_options
  end

  def checker_tag(object, field_name, resource_name = object.class.table_name)
    data = {}
    data[:checked_url]   = polymorphic_path(["enable_#{field_name}", resource_name])
    data[:unchecked_url] = polymorphic_path(["disable_#{field_name}", resource_name])

    html_options = {id: "#{field_name}_checker", data: data, class: 'form-control Checker', type: 'checkbox'}
    html_options['checked'] = 'checked' if object["#{field_name}_enabled"]

    tag :input, html_options
  end

  # @return [String]
  def current_profile_path
    profile_path(current_user.object)
  end

  # @param text [String]
  # @return [String]
  def super_highlight(text)
    q = params[:q]
    if q.present?
      highlights = q.split(/\W+/).reject { |token| token.length < 3} << q
      begin
      highlight(text, highlights)
      rescue
        raise text.inspect
      end
    else
      text
    end
  end

  # Returns number displaying subscription cost
  # @param cost [Integer, Float, String]
  # @param opts [Hash]
  # @return [String]
  def super_number_to_currency(cost, opts = {})
    cost = cost.to_f
    ceil_cost = cost.to_i

    if opts[:use_ceil] == false
      cost = cost - ceil_cost > 0 ? cost : ceil_cost
      number_to_currency(cost, opts)
    else
      cost - ceil_cost > 0 ? number_to_currency(cost, opts) : ceil_cost
    end
  end

  # @param profile [ProfileDecorator]
  # @return [String]
  def render_benefits(profile)
    render '/benefits/list', benefits: profile.benefits
  end

  def sort_direction_params(field_name)
    direction = params[:sort_direction] == 'desc' ? 'asc' : 'desc'
    {sort_by: field_name, sort_direction: direction}
  end

  # @param user [User]
  # @return [String]
  def link_to_user(user)
    user = user.object if user.kind_of? BaseDecorator
    link_to_if user.has_profile_page?, user.name.first(40).gsub(/ /, '&nbsp;').html_safe, profile_url(user)
  end

  # @param video [Video]
  # @return [String, nil]
  def video_player(video)
    content_tag(:div, nil,
                id: "Upload__#{video.id}",
                class: 'VideoPlayer',
                data: { file:     video.rtmp_path,
                        original: video.original_url,
                        image:    video.preview_url,
                        primary: 'html5' }) if video
  end

  # @param audio [Audio]
  # @return [String, nil]
  def audio_player(audio)
    content_tag(:div, nil,
                id: "Upload__#{audio.id}",
                class: 'AudioPlayer',
                data: { file:     audio.rtmp_path,
                        original: audio.original_url,
                        primary: 'html5' }) if audio
  end
end
