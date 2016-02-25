# Renders remote URL into html container
# If a link is clicked - container acts as IFrame
#
# @data use_anchor [true, false, null] if true does not use @url and changes page anchor
# @data url [String, null] url to load on widget initialized.
class bud.widgets.AjaxContainer extends bud.Widget
  @SELECTOR: '.AjaxContainer'

  initialize: ->
    @url = @$container.data('url')
    @use_anchor = @$container.data('use_anchor')
    ajaxify_flag = @$container.data('ajaxify_links')
    @ajaxify_links = _.isUndefined(ajaxify_flag) || ajaxify_flag
    @use_html5_history = @$container.data('use_html5_history')
    @redirects = @$container.data('redirects')
    @init_links()

    if @use_anchor
      bud.sub('window.hashchange', @location_changed)
      @location_changed()
    else if @use_html5_history
      bud.sub('window.locationchange', @location_changed)
    else
      @render()

  destroy: ->
    bud.unsub('window.hashchange', @location_changed)
    bud.unsub('window.locationchange', @location_changed)

  location_changed: =>
    if @use_anchor
      hash = window.location.hash.substr(1)
      if hash.match(/^\//)
        @url = hash
        @render()
    else if @use_html5_history
      @url = window.location.href
      @render()

  render: ->
    if @url
      if bud.is_mobile.any()
        window.location.replace(@redirects?[@url] || @url)
      else
        @render_path(@url)

  link_clicked: (e) =>
    link = $(e.currentTarget)
    href = link.attr('href')

    return true if link.hasClass('js-widget') || _.isEmpty(href) || /^#/.test(href) || link.attr('target') == '_blank'

    if @use_html5_history
      bud.goto(href)
    else
      @render_path(href)

    return false

  render_path: (request_path) ->
    @$container.addClass('pending')
    callbacks = {success: @render_page, replace: @replace_page, append: @append_page, prepend: @prepend_page, after: @on_response_received}
    bud.Ajax.getJson(request_path, @request_params(), callbacks)

  append_page: (response) =>
    bud.append_html(@$container, response)

  prepend_page: (response) =>
    bud.prepend_html(@$container, response)

  replace_page: (response) =>
    bud.replace_container(@$container, response)

  render_page: (response) =>
    bud.replace_html(@$container, response)

  on_response_received: (response) =>
    @$container.removeClass('pending')
    @init_links()

  request_params: -> {}

  init_links: ->
    @$container.find('a').click(@link_clicked) if @ajaxify_links
