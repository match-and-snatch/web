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
    @$container.find('a').click @link_clicked

    if @use_anchor
      bud.sub('window.hashchange', @location_changed)
      @location_changed()
    else
      @render()

  location_changed: =>
    hash = window.location.hash.substr(1)
    if hash.match(/^\//)
      @url = hash
      @render()

  render: ->
    @render_path(@url) if @url

  link_clicked: (e) =>
    link = $(e.currentTarget)
    @render_path(link.attr('href'))
    return false

  render_path: (request_path) ->
    @$container.addClass('pending')
    callbacks = {success: @render_page, replace: @replace_page, append: @append_page, prepend: @prepend_page, after: @on_response_received}
    bud.Ajax.get(request_path, @request_params(), callbacks)

  append_page: (response) =>
    bud.append_html(@$container, response['html'])

  prepend_page: (response) =>
    bud.prepend_html(@$container, response['html'])

  replace_page: (response) =>
    bud.replace_container(@$container, response['html'])

  render_page: (response) =>
    bud.replace_html(@$container, response['html'])

  on_response_received: (response) =>
    @$container.removeClass('pending')

  request_params: -> {}
