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

  def contribution_text(contribution)
    if contribution.recurring?
      "Monthly recurring contribution #{cents_to_dollars(contribution.amount)}"
    else
      "One-time contribution #{cents_to_dollars(contribution.amount)}"
    end
  end

  # @param likale [Concerns::Likable]
  # @return [String, nil]
  def likes_text(likable)
    data = likable.likers_data
    return if data[:total_count].zero?

    more_count = data[:more_count]
    recent_liker = data[:recent_liker]

    case more_count
    when 0
      recent_liker
    else
      path = likable.is_a?(Post) ? post_likes_path(likable) : polymorphic_path([likable, :likes])
      "#{recent_liker} and #{content_tag :span, "#{more_count} other likes", class: 'Hover tmp', data: {url: path, target: likable_id(likable)}}"
    end.try(:html_safe)
  end

  def likable_id(likable)
    "other-likers-#{likable.class.name}-#{likable.id}"
  end

  def object_checker_tag(object, field_name, options = {})
    data = {}
    data[:checked_url]   = options.delete(:checked_url) || polymorphic_path(["enable_#{field_name}", object])
    data[:unchecked_url] = options.delete(:unchecked_url) || polymorphic_path(["disable_#{field_name}", object])

    html_options = {id: "#{field_name}_#{object.id}_#{object.class.name}_checker", data: data, class: 'Checker', type: 'checkbox'}
    html_options['checked'] = 'checked' if options.delete(:checked) || object["#{field_name}_enabled"]
    html_options.merge! options

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
  def cents_to_dollars(cost, opts = {})
    cost = cost.to_f / 100.0
    ceil_cost = cost.to_i

    if opts[:use_ceil]
      cost - ceil_cost > 0 ? number_to_currency(cost, opts) : "$#{ceil_cost}"
    else
      number_to_currency(cost - ceil_cost > 0 ? cost : ceil_cost, opts)
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

  # @param video [Video]
  # @return [String, nil]
  def video_player(video)
    if video.low_quality_playlist_url
      playlist_url = playlist_video_path(video.id, format: 'm3u8')
    end

    content_tag(:div, nil,
                id: "Upload__#{video.id}",
                class: 'VideoPlayer',
                data: { file:     video.rtmp_path,
                        hdfile:   video.hd_rtmp_path,
                        playlist: playlist_url,
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

  # @param path [String, User]
  # @return [String]
  def mobile_url(path = nil)
    if path.is_a?(User)
      profile_url(path, host: APP_CONFIG['mobile_site_url'], protocol: :https)
    else
      [APP_CONFIG['mobile_site_url'], path].join('/')
    end
  end

  def mobile_redirects
    host = if Rails.env.development?
             "#{request.scheme}://#{request.host}:8080"
           else
             APP_CONFIG['mobile_site_url']
           end

    APP_CONFIG['mobile_redirects'].inject({}) do |redirects, (key, val)|
      redirects[key] = "#{host}#{val}"
      redirects
    end.to_json
  end

  def special_offer_message(user)
    if user.has_special_offer?
      user.profile_page_data.special_offer.try(:html_safe)
    else
      'Your monthly payment will be auto-renewed unless you decide to cancel. You can cancel anytime.'
    end
  end

  def profile_cost(user)
    "#{cents_to_dollars(user.subscription_cost)}#{'*' if user.has_special_offer?}"
  end

  def dashboard_link_to(title, array)
    link_to title, [current_user.current_role].concat(array)
  end

  def sort_profile_owners_link(title, field)
    dashboard_link_to title, [:profile_owners, sort_direction_params(field)]
  end

  def sort_profile_deserters_link(title, field)
    dashboard_link_to title, [:profile_deserters, sort_direction_params(field)]
  end

  def sort_potential_violators_link(title, field)
    sort_dashboard_link :potential_violators, title, field
  end

  def sort_dashboard_link(resource, title, field)
    dashboard_link_to title, [resource, add_request_params(sort_direction_params(field))]
  end

  def add_request_params(hash)
    request.GET.except('authenticity_token').merge(hash)
  end

  def dashboard_link_to_user(user, truncate: true, link_title: user.name)
    if current_user.admin?
      link_to link_title, admin_profile_owner_path(user.id), class: (truncate ? 'truncate' : nil)
    else
      if user.slug.present?
        link_to link_title, profile_path(user.slug), target: '_blank'
      else
        link_title
      end
    end
  end

  def login_as_user_path(user_id)
    if current_user.admin?
      login_as_admin_user_path(user_id)
    elsif current_user.sales?
      login_as_sales_user_path(user_id)
    else
      '#'
    end
  end

  # @return [Redcarpet::Markdown]
  def markdown
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  end

  # @param str [String]
  # @return [String]
  def markdown_to_html(str)
    markdown.render(str).html_safe
  end
end
